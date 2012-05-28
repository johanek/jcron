#!/usr/bin/env ruby

# require 'rubygems'
# require 'popen4'
# 
# # Setup DB
# server = CouchDB::Server.new "couchdb", 5984
# database = CouchDB::Database.new server, "test"
# database.create_if_missing!
# 
# job = Hash.new()
# job['cmd'] = "sleep 1 ; echo hi ; sleep 1 ; echo hi ; ls /tmp/blah ; sleep 1 ; echo hi ; sleep 1 ; echo hi ; sleep 1 "
# job['starttime'] = Time.now
# status = POpen4::popen4(job['cmd']) do |stdout, stderr, stdin, pid|
#   job['pid'] = pid
#   # Publish what we know here
#   p job
#   job['stdout'] = stdout.read.strip
#   job['stderr'] = stderr.read.strip
# end
# job['endtime'] = Time.now
# job['runtime'] = job['endtime'] - job['starttime']
# job['exitcode'] = status.exitstatus
# job.inspect

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "lib"))
require 'jcron'
server = 'couchdb'
a = Jcron::Runjob.new(server)
a.run("curl http://www.google.com")

# #search by key
# b = a.get("/cron/_design/cronview/_view/by_runtime?key=5.025178")
