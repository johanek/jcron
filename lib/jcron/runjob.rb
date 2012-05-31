module Jcron
  class Runjob

    def initialize(server, port='5984')
      @baseuri = "/cron/"
      @couchdb = Jcron::Couch.new(server, port)
    end
    
    def run(cmd)
      job = {
        'host' => Socket.gethostname,
        'cmd'  => cmd,
        'starttime' => Time.now
      }
      
      @uri = "#{@baseuri}#{Time.now.utc.iso8601}_#{job['host']}_#{md5(job['cmd'])}"
      
      status = POpen4::popen4(job['cmd']) do |stdout, stderr, stdin, pid|

        # Publish known job info at start
        job['pid'] = pid
        result = @couchdb.put(@uri, job.to_json)
        # Capture output and couchdb revision
        job.merge! '_rev' => JSON::parse(result.body)['rev'], 'stdout' => stdout.read.strip, 'stderr' => stderr.read.strip
      end
      
      # Finish data collection & publish completed job
      job.merge! 'endtime' => Time.now, 'runtime' => Time.now - job['starttime'], 'exitcode' => status.exitstatus
      @couchdb.put(@uri, job.to_json)
    end

    def md5(cmd)
      Digest::MD5.hexdigest(cmd)
    end

  end
end