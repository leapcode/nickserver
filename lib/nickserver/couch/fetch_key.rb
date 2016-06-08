require 'nickserver/couch_db/source'
require 'nickserver/adapters/em_http'

module Nickserver; module Couch
  class FetchKey

    def initialize(options={})
      @source = Nickserver::CouchDB::Source.new(adapter)
    end

    def get(uid, &block)
      source.query(uid, &block)
    end

    protected

    attr_reader :source

    def adapter
      @adapter ||= Nickserver::Adapters::EmHttp.new
    end


  end
end; end
