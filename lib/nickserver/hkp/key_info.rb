require 'cgi'
require 'nickserver/hkp'

module Nickserver::Hkp
  #
  # Class to represent the key information result from a query to a key server
  # (but not the key itself).
  #
  # The initialize method parses the hkp 'machine readable' output.
  #
  # format definition of machine readable index output is here:
  # http://tools.ietf.org/html/draft-shaw-openpgp-hkp-00#section-5.2
  #
  class KeyInfo
    attr_accessor :uids

    def initialize(hkp_record)
      uid_lines = hkp_record.split("\n")
      pub_line  = uid_lines.shift
      @properties = pub_line.split(':')[1..-1]
      @uids = extract_uids(uid_lines)
    end

    def keyid
      properties.first
    end

    def algo
      properties.second
    end

    def keylen
      properties[2].to_i
    end

    def creationdate
      created = properties[3]
      Time.at(created.to_i)
    end

    def expirationdate
      expires = properties[4]
      Time.at(expires.to_i)
    end

    def flags
      properties.last
    end

    def rsa?
      algo == '1'
    end

    def dsa?
      algo == '17'
    end

    def revoked?
      flags =~ /r/
    end

    def disabled?
      flags =~ /d/
    end

    def expired?
      flags =~ /e/
    end

    protected

    attr_reader :properties

    def extract_uids(uid_lines)
      uid_lines.map do |uid_line|
        # for now, ignore the expirationdate and flags of uids.
        # sks does return them anyway
        uid, _creationdate, _expirationdate, _flags = uid_line.split(':')[1..-1]
        CGI.unescape(uid.sub(/.*<(.+)>.*/, '\1'))
      end
    end
  end
end
