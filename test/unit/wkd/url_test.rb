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

    # we can be pretty sure this works for the person who proposed it
    def test_gnupg_testuser_email
      url = Url.new test_user_email
      assert_equal test_user_url, url.to_s
    end

    protected

    def test_user_email
      Nickserver::EmailAddress.new 'dewey@test.gnupg.org'
    end

    def test_user_url
      'https://test.gnupg.org/.well-known/openpgpkey/hu/' \
        '1g8totoxbt4zf6na1sukczp5fiewr1oe'
    end

    def sample_email
      Nickserver::EmailAddress.new 'Joe.Doe@Example.ORG'
    end

    def sample_url
      'https://example.org/.well-known/openpgpkey/hu/' \
        'iy9q119eutrkn8s1mk4r39qejnbu3n5q'
    end
  end
end
