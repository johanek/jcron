module Jcron
  class Findjob

    def initialize(server, port='5984')
      @baseuri = "/cron/"
      @couchdb = Jcron::Couch.new(server, port)
    end
    
    def find(cmd)
      uri = @baseuri + "_design/cronview/_view/by_cmd?key=\"#{cmd}\""
      result = @couchdb.get(uri)
      JSON.parse(result.body)
    end

    def md5(cmd)
      Digest::MD5.hexdigest(cmd)
    end

  end
end