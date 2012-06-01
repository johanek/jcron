#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'rubygems'
require 'cron-spec'
require 'jcron'

cronfile = "./jcrontab"
@publish = true

def process(cmd)
  schedule = cmd[/(\S+\s+){5}/]
  cmd[/(\S+\s+){5}/] = ''
  
  begin
    cs = CronSpec::CronSpecification.new(schedule)
  rescue => err
    puts "Exception: #{err}"
  end
  
  if cs.is_specification_in_effect?(Time.now) 
    #Run Job
    server = 'couchdb'
    job = Jcron::Runjob.new(server)
    job.run(cmd)

    # Publish
    if @publish
      require 'eventasaurus'
      ident = 'cron'
      message = %(Cronjob #{cmd} finished on ##{Socket.gethostname} http://couchdb:5984/_utils/database.html?cron)
      Eventasaurus::publish(ident,message)
    end
  else
    # check status of last job
    puts "#{cmd} - next run in #{next_run(schedule)['minutes']} minutes, last run #{last_run(schedule)['minutes']} minutes ago"
  end
end

def next_run(schedule)
  cs = CronSpec::CronSpecification.new(schedule)
  result = { 'time' => Time.now }
  while cs.is_specification_in_effect?(result['time']) == false
    result['time'] += 60
  end
  result['minutes'] = ((result['time'] - Time.now) / 60).to_i + 1
  result
end

def last_run(schedule)
  cs = CronSpec::CronSpecification.new(schedule)
  result = { 'time' => Time.now }
  while cs.is_specification_in_effect?(result['time']) == false
    result['time'] -= 60
  end
  result['minutes'] = ((Time.now - result['time']) / 60).to_i
  result
end


# Iterate over lines in crontab
begin
  crontab = File.new(cronfile, "r")
  while line = crontab.gets
    process(line.chomp)
  end
  crontab.close
rescue => err
  puts "Exception: #{err}"
end

