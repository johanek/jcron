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

  desc "find [cmd]", "find cmd in history"
  def find(*cmd)
    die("Must provide command to find") unless cmd.any?
    cmd = cmd.join(' ')
    server = 'couchdb'
    job = Jcron::Findjob.new(server)
    puts job.fulltext_find(cmd).to_yaml
  end

  desc "search [cmd]", "search for cmd in history"
  def search(cmd)
    die("Must provide command to find") unless cmd.any?
    server = 'couchdb'
    job = Jcron::Findjob.new(server)
    puts job.keyword_find(cmd).to_yaml
  end


  
end

CLI.start
