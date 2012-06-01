#!/usr/bin/ruby

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'rubygems'
require 'thor'
require 'jcron'

def die(msg)
  puts msg
  exit 1
end

class CLI < Thor

  desc "ex [cmd]", "run job"
  def ex
    ARGV.delete("ex")
    cmd = ARGV.join(' ')
    die("Must provide command to ex") unless ARGV.any?

    server = 'couchdb'
    job = Jcron::Runjob.new(server)
    job.run(cmd)
  end
  
end

CLI.start
