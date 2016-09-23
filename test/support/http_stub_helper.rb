module HttpStubHelper

  def stubbing_http
    Nickserver::Adapters::CelluloidHttp.stub :new, adapter do
      yield
    end
    adapter.verify
  end

  def stub_nicknym_available_response(domain, response = {})
    stub_http_request :get, "https://#{domain}/provider.json",
      response: response
  end

  def stub_sks_vindex_reponse(uid, response = {})
    stub_http_request :get, config.hkp_url,
      query: {op: 'vindex', search: uid, exact: 'on', options: 'mr', fingerprint: 'on'},
      response: response
  end

  def stub_sks_get_reponse(key_id, response = {})
    stub_http_request :get, config.hkp_url,
      query: {op: 'get', search: "0x"+key_id, exact: 'on', options: 'mr'},
      response: response
  end

  def stub_couch_response(uid, response = {})
    query = "\?key=#{"%22#{uid}%22"}&reduce=false"
    stub_http_request :get,
      /#{Regexp.escape(config.couch_url)}.*#{query}/,
      response: response
  end

  def stub_http_request(verb, url, options = {})
    response = {status: 200, body: ""}.merge(options.delete(:response) || {})
    options = nil if options == {}
    adapter.expect :get, [response[:status], response[:body]],
      [url, options].compact
  end

  def adapter
    @adapter ||= MiniTest::Mock.new
  end
end
