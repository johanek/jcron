module Jcron
  class Findjob

    def initialize(server, port='5984')
      @baseuri = "/cron/"
      @couchdb = Jcron::Couch.new(server, port)
    end
    
    def fulltext_find(cmd)
      uri = %(#{@baseuri}_design/cronview/_view/by_cmd?key="#{cmd}")
      result = @couchdb.get(uri)
      JSON.parse(result.body)
    end

    def keyword_find(cmd)
      uri = %(#{@baseuri}_design/cronview/_view/by_cmd_keyword?key="#{cmd}")
      result = @couchdb.get(uri)
      JSON.parse(result.body)
    end
    
    def checkjob(cmd, time)
      uri = "#{@baseuri}#{Jcron::short_isotime(time)}_#{Socket.gethostname}_#{Jcron::md5(cmd)}"
      result = @couchdb.get(uri)
      JSON.parse(result.body)
    end

  end
end
