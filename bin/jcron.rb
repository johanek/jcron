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

def parser(hash)
  hash['rows'].each do |row|
    row['value'].each_pair do |k,v|
      puts "#{k} - #{v}"
    end
  end
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
    stomp = Eventasaurus::Producer.new('event')
    stomp.topic = 'eventasaurus'
    msg = {
      'ident' => 'cron',
      'timestamp' => Time.now.utc.iso8601,
      'message' => "Cronjob #{cmd} finished on ##{Socket.gethostname} http://couchdb:5984/_utils/database.html?cron"
    }
    stomp.pub(msg.to_json)
    stomp.close
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
