#!/usr/bin/ruby

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'rubygems'
require 'thor'
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
  def ex(*cmd)
    die("Must provide command to ex") unless cmd.any?
    cmd = cmd.join(' ')
    server = 'couchdb'
    job = Jcron::Runjob.new(server)
    job.run(cmd)
  end
  
  desc "find [cmd]", "find cmd history"
  def find(*cmd)
    die("Must provide command to find") unless cmd.any?
    cmd = cmd.join(' ')
    server = 'couchdb'
    job = Jcron::Findjob.new(server)
    parser(job.find(cmd))
  end
end

CLI.start