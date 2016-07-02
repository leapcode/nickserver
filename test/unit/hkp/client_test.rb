require 'test_helper'
require 'nickserver/hkp/client'

module Nickserver::Hkp
  class ClientTest < Minitest::Test

    def test_get_key_infos_by_email
      adapter_expects_query op: "vindex",
        search: email,
        options: "mr",
        fingerprint: "on",
        exact: "on"
      client.get_key_infos_by_email(email)
      @adapter.verify
    end

    def test_key_by_fingerprint
      adapter_expects_query op: "get",
        search: "0x#{fingerprint}",
        options: "mr",
        exact: "on"
      client.get_key_by_fingerprint(fingerprint)
      @adapter.verify
    end

    def client
      @client ||= Client.new @adapter
    end

    def adapter_expects_query(query = {})
      adapter_expects Nickserver::Config.hkp_url, query: query
    end

    def adapter_expects(*args)
      @adapter = Minitest::Mock.new
      @adapter.expect :get, dummy_response,
        args
    end

    def email
      'dummy_email'
    end

    def fingerprint
      'dummy_fingerprint'
    end

    def dummy_response
      [200, 'dummy_response']
    end

  end
end
