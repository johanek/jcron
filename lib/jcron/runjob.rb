


module Jcron
  class Runjob

    def initialize
      server = "couchdb"
      port = "5984"
      @baseuri = "/cron/"
      @couchdb = Jcron::Couch.new(server, port)
    end

    def tester
      job = Hash.new()
      job['host'] = Socket.gethostname
      job['cmd'] = "sleep 1 ; echo hi ; sleep 1 ; echo hi ; ls /tmp/blah ; sleep 1 ; echo hi ; sleep 1 ; echo hi ; sleep 1 "
      job['starttime'] = Time.now
      @uri = @baseuri + Time.now.utc.iso8601 + "_" + job['host'] + "_" + md5(job['cmd'])
      status = POpen4::popen4(job['cmd']) do |stdout, stderr, stdin, pid|
        job['pid'] = pid
        # Publish what we know here
        result = @couchdb.put(@uri, job.to_json)
        job['_rev'] = JSON::parse(result.body)['rev']
        p @uri
        p job['_rev']
        job['stdout'] = stdout.read.strip
        job['stderr'] = stderr.read.strip
      end
      job['endtime'] = Time.now
      job['runtime'] = job['endtime'] - job['starttime']
      job['exitcode'] = status.exitstatus
      job['_rev'] =
      @couchdb.put(@uri, job.to_json)
    end

    def md5(cmd)
      Digest::MD5.hexdigest(cmd)
    end

  end


end