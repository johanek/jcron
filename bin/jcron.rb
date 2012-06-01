#!/usr/bin/ruby

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'rubygems'
require 'thor'
require 'socket'
require 'yaml'
require 'jcron'

def die(msg)
  puts msg
  exit 1
end

class CLI < Thor

  desc "ex [cmd]", "run job"
  def ex(*_)
    ARGV.delete("ex")
    cmd = ARGV.join(' ')
    die("Must provide command to ex") unless ARGV.any?

    # Run Job
    server = 'couchdb'
    job = Jcron::Runjob.new(server)
    job.run(cmd)

    # Publish
    require 'eventasaurus'
    ident = 'cron'
    message = "Cronjob #{cmd} finished on ##{Socket.gethostname} http://couchdb:5984/_utils/database.html?cron"
    Eventasaurus::publish(ident,message)
  end

  desc "find [cmd]", "find cmd history"
  def find(*cmd)
    die("Must provide command to find") unless cmd.any?
    cmd = cmd.join(' ')
    server = 'couchdb'
    job = Jcron::Findjob.new(server)
    puts job.find(cmd).to_yaml
  end

  
end

CLI.start
