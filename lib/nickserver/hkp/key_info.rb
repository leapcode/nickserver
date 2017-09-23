require 'cgi'
require 'nickserver/hkp'

#
# Class to represent the key information result from a query to a key server
# (but not the key itself).
#
# The initialize method parses the hkp 'machine readable' output.
#
# format definition of machine readable index output is here:
# http://tools.ietf.org/html/draft-shaw-openpgp-hkp-00#section-5.2
#
module Nickserver::Hkp
  class KeyInfo
    attr_accessor :uids, :keyid, :algo, :flags

    def initialize(hkp_record)
      uid_lines = hkp_record.split("\n")
      pub_line  = uid_lines.shift
      @keyid, @algo, @keylen_s, @creationdate_s, @expirationdate_s, @flags = pub_line.split(':')[1..-1]
      @uids = []
      uid_lines.each do |uid_line|
        uid, _creationdate, _expirationdate, _flags = uid_line.split(':')[1..-1]
        # for now, ignore the expirationdate and flags of uids. sks does return them anyway
        @uids << CGI.unescape(uid.sub(/.*<(.+)>.*/, '\1'))
      end
    end

    def keylen
      @keylen ||= @keylen_s.to_i
    end

    def creationdate
      @creationdate ||= begin
        Time.at(@creationdate_s.to_i) if @creationdate_s
      end
    end

    def expirationdate
      @expirationdate ||= begin
        Time.at(@expirationdate_s.to_i) if @expirationdate_s
      end
    end

    def rsa?
      @algo == '1'
    end

    def dsa?
      @algo == '17'
    end

    def revoked?
      @flags =~ /r/
    end

    def disabled?
      @flags =~ /d/
    end

    def expired?
      @flags =~ /e/
    end
  end
end
