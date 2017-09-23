require 'test_helper'
require 'nickserver/wkd/url'
require 'nickserver/email_address'

module Nickserver::Wkd
  class UrlTest < Minitest::Test
    # TODO: test utf8 behavior

    # https://tools.ietf.org/html/draft-koch-openpgp-webkey-service-00#section-3.1
    def test_sample_from_draft
      url = Url.new sample_email
      assert_equal sample_url, url.to_s
    end

    protected

    def sample_email
      Nickserver::EmailAddress.new 'Joe.Doe@Example.ORG'
    end

    def sample_url
      'https://example.org/.well-known/openpgpkey/' +
        'hu/example.org/iy9q119eutrkn8s1mk4r39qejnbu3n5q'
    end
  end
end
