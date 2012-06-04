#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'jcron'

dbserver = 'couchdb'
dbport = 5984
db = 'cron'
dburi = "/#{db}/"
viewuri = "#{dburi}/_design/cronview"

# Create DB
couch = Jcron::Couch.new(dbserver, dbport)
# put requires json content, but db server ignores this content anyway
nothing = {}
couch.put(dburi, nothing.to_json)

# Create View
view = {
  "_id" => "_design/cronview",
  "language" => "javascript",
  "views" =>
	{
	   "by_host" => {
	       "map" => "function(doc) { if (doc.host)  emit(doc.host, doc) }"
	   },
	   "by_runtime" => {
	       "map" => "function(doc) { if (doc.runtime)  emit(doc.runtime, doc) }"
	   },
	   "by_starttime" => {
	       "map" => "function(doc) { if (doc.starttime)  emit(doc.starttime, doc) }"
	   },
	   "by_endtime" => {
	       "map" => "function(doc) { if (doc.endtime)  emit(doc.endtime, doc) }"
	   },
	   "by_cmd" => {
	       "map" => "function(doc) { if (doc.cmd)  emit(doc.cmd, doc) }"
	   },
	   "by_exitcode" => {
	       "map" => "function(doc) { if (doc.exitcode)  emit(doc.exitcode, doc) }"
	   },
	   "by_cmd_keyword" => {
         "map" => "function(doc) { var stringarray = doc.cmd.split(/[^A-Z0-9\-_]+/i); for(var idx in stringarray) emit(stringarray[idx],doc); }"
     }
	}
}
couch.put(viewuri, view.to_json)