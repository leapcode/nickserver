require 'nickserver/reel_server'

module HttpStubHelper

  def stubbing_http
    Nickserver::ReelServer::DEFAULT_ADAPTER_CLASS.stub :new, adapter do
      yield
    end
    adapter.verify
  end

  def stub_nicknym_available_response(domain, response = {})
    stub_http_get "https://#{domain}/provider.json",
      response,
      Hash
  end

  def stub_sks_vindex_reponse(uid, response = {})
    stub_http_get config.hkp_url, response,
      query: {op: 'vindex', search: uid, exact: 'on', options: 'mr', fingerprint: 'on'}
  end

  def stub_sks_get_reponse(key_id, response = {})
    stub_http_get config.hkp_url, response,
      query: {op: 'get', search: "0x"+key_id, exact: 'on', options: 'mr'}
  end

  def stub_couch_response(uid, response = {})
    query = "\?key=#{"%22#{uid}%22"}&reduce=false"
    stub_http_get(/#{Regexp.escape(config.couch_url)}.*#{query}/, response)
  end

  private

  def stub_http_get(url, response, options = nil)
    response = {status: 200, body: ""}.merge(response || {})
    adapter.expect :get, [response[:status], response[:body]],
      [url, options].compact
  end

  def adapter
    @adapter ||= MiniTest::Mock.new
  end
end
