require 'rubygems'
require 'popen4'
require 'net/http'
require 'digest/md5'
require 'json'
require 'socket'
require 'uri'
require 'time'
require 'jcron/runjob'
require 'jcron/couch'
require 'jcron/findjob'

module Jcron
  class << self
    
    def short_isotime(time)
      time.utc.strftime("%Y-%m-%dT%H:%MZ")
    end
    
    def md5(cmd)
      Digest::MD5.hexdigest(cmd)
    end
    
  end
end