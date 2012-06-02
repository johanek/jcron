#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))
require 'rubygems'
require 'cron-spec'
require 'jcron'
require 'eventasaurus'

cronfile = "./jcrontab"
@publish = true
@server = 'couchdb'
@ident = 'cron'

def process(line)
  # Seperate schedule/interval/command from cronline
  # * * * * * / 60 / do_it.sh
  fields = line.split(/\s+/)
  schedule = fields[0..4].join(' ')
  interval = fields[5].to_i
  cmd = fields[6..-1].join(' ')
  
  # Sanatise interval
  interval = 60 if interval == "*"
  schedule_interval = scheduled_interval(schedule)
  interval = schedule_interval - 1 if schedule_interval <= interval
  interval = 1 if schedule == "* * * * *"
  #puts "#{cmd} #{last_run(schedule)['minutes'].class} #{interval.class}"
  
  begin
    cs = CronSpec::CronSpecification.new(schedule)
  rescue => err
    puts "Exception: #{err}"
  end
  
  # Do reporting
  if last_run(schedule)['minutes'] == interval
    #puts "matched #{cmd}"
    report = check_last_job(schedule, cmd)
    last_run_at = Time.now - (interval * 60)
    url = gen_url(last_run_at,cmd)
    
    if report['error']
      message = %(WARNING expected run of #{cmd} at #{last_run_at} ##{Socket.gethostname} not found!)
    end
    
    if report['starttime']
      message = %(WARNING #{cmd} at #{report['starttime']} on ##{Socket.gethostname} not completed in expected timeframe! #{url}) unless report['endtime']
    end
    
    if report['stderr']
      message = %(NOTICE #{cmd} at #{report['starttime']} on ##{Socket.gethostname} completed with stderr #{url}) if report['stderr'].any?
    end
        
    Eventasaurus::publish(@ident,message) if message
    
  end
  
  if cs.is_specification_in_effect?(Time.now) 
    #Run Job
    job = Jcron::Runjob.new(@server)
    result = job.run(cmd)

    # Publish
    message = %(OK #{cmd} finished in #{result['runtime']} on ##{Socket.gethostname} #{gen_url(Time.now,cmd)})
    
    if result['exitcode']
      message = %(ERROR #{cmd} at #{result['starttime']} on ##{Socket.gethostname} exited with status #{result['exitcode']}! #{url}) unless result['exitcode'] == 0
    end
    
    Eventasaurus::publish(@ident,message)
  end
end

def next_run(schedule)
  cs = CronSpec::CronSpecification.new(schedule)
  result = { 'time' => Time.now }
  while cs.is_specification_in_effect?(result['time']) == false
    result['time'] += 60
  end
  result['seconds'] = (result['time'] - Time.now).to_i
  result['minutes'] = (result['seconds'] / 60).to_i + 1
  result
end

def last_run(schedule)
  cs = CronSpec::CronSpecification.new(schedule)
  result = { 'time' => Time.now - 60 }
  while cs.is_specification_in_effect?(result['time']) == false
    result['time'] -= 60
  end
  result['seconds'] = (Time.now - result['time']).to_i
  result['minutes'] = ((Time.now - result['time']) / 60).to_i
  result
end

def scheduled_interval(schedule)
  next_run(schedule)['minutes'] + last_run(schedule)['minutes']
end

def check_last_job(schedule, cmd)    
  job = Jcron::Findjob.new(@server)
  lastrun = Time.now - last_run(schedule)['seconds']
  begin
    result = job.checkjob(cmd, lastrun)
  rescue RuntimeError
    result = { "error" => "No record found for #{cmd} at #{lastrun}" }
  end
  result
end

def gen_url(time, cmd)
  #http://couchdb:5984/_utils/document.html?cron/2012-06-02T13%3A40Z_Johan-van-den-Dorpes-MacBook.local_e27f6f3c9fe8257f371328f684521764
  "http://#{@server}:5984/_utils/document.html?cron/#{Jcron::short_isotime(time)}_#{Socket.gethostname}_#{Jcron::md5(cmd)}"
end

# Iterate over lines in crontab
begin
  crontab = File.new(cronfile, "r")
  while line = crontab.gets
    line.chomp!
    #skip comments & blank lines
    next if /\S/ !~ line
    next if /^#/ =~ line
    process(line)
  end
  crontab.close
rescue => err
  puts "Exception: #{err}"
end

