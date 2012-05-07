require 'rubygems'
require 'popen4'

module Jcron
  class runjob
    job = Hash.new()
    job['cmd'] = "sleep 1 ; echo hi ; sleep 1 ; echo hi ; ls /tmp/blah ; sleep 1 ; echo hi ; sleep 1 ; echo hi ; sleep 1 "
    job['starttime'] = Time.now
    status = POpen4::popen4(job['cmd']) do |stdout, stderr, stdin, pid|
      job['pid'] = pid
      # Publish what we know here
      p job
      job['stdout'] = stdout.read.strip
      job['stderr'] = stderr.read.strip
    end
    job['endtime'] = Time.now
    job['runtime'] = job['endtime'] - job['starttime']
    job['exitcode'] = status.exitstatus
    job.inspect
  end
end

