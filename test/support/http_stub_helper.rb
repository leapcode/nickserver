require 'nickserver/reel_server'

module HttpStubHelper
  protected

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

  def stub_sks_vindex_reponse(_uid, response = {})
    stub_http_get config.hkp_url,
                  response,
                  query: vindex_query
  end

  def vindex_query
    { op: 'vindex',
      search: uid,
      exact: 'on',
      options: 'mr',
      fingerprint: 'on' }
  end

  def stub_sks_get_reponse(_key_id, response = {})
    stub_http_get config.hkp_url,
                  response,
                  query: sks_get_query
  end

  def sks_get_query
    { op: 'get',
      search: '0x' + key_id,
      exact: 'on',
      options: 'mr' }
  end

  def stub_couch_response(uid, response = {})
    query = "\?key=#{"%22#{uid}%22"}&reduce=false"
    stub_http_get(/#{Regexp.escape(config.couch_url)}.*#{query}/, response)
  end

  def stub_http_get(url, response, options = nil)
    response = { status: 200, body: '' }.merge(response || {})
    adapter.expect :get, [response[:status], response[:body]],
                   [url, options].compact
  end

  def adapter
    @adapter ||= MiniTest::Mock.new
  end
end
