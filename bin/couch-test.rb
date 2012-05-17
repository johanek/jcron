#!/usr/bin/ruby

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'rubygems'
require 'jcron'

server = "couchdb"
port = "5984"

couchdb = Jcron::Couch.new(server, port)
