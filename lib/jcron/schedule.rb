module Jcron
  class Schedule
    
    attr_accessor :cronfile
    
    def initialize(configfile)
      read_config(configfile)
    end
    
    def read_config(configfile)
    	config = YAML.load_file(configfile)
    	@server = config['dbserver']
    	@port = config['dbport']
    	@database = config['database']
    	self.cronfile = config['cronfile']
    	@publish = config['publish']
    end

    def process(line)
      begin        
        # Seperate schedule/interval/command from cronline
        # * * * * * / 60 / do_it.sh    
        if line =~ /^@/
          line.gsub!(/@midnight|@daily/, "0 0 * * *")
          line.gsub!(/@hourly/, "0 * * * *")
          line.gsub!(/@weekly/, "0 0 * * )")
          line.gsub!(/@monthly/, "0 0 1 * *")
          line.gsub!(/@yearly|@annually/, "0 0 1 1 *")
        end
        fields = line.split(/\s+/)
        raise if fields.count < 7
        schedule = fields[0..4].join(' ')
        interval = fields[5].to_i
        cmd = fields[6..-1].join(' ')


        # Sanitise interval
        interval = 60 if interval == "*"
        schedule_interval = scheduled_interval(schedule)
        interval = schedule_interval - 1 if schedule_interval <= interval
        interval = 1 if schedule == "* * * * *"

      rescue => err
        message = %(Problem with jcrontab schedule for "#{line}"" on ##{Socket.gethostname})
        Eventasaurus::publish(@ident,message) if @publish
        puts message
        puts err
        return
      end

      # create cron-spec object here - catch any errors in schedule before continuing
      cs = CronSpec::CronSpecification.new(schedule)

      # At reporting interval, check the last run of job and report problems
      if last_run(schedule)['minutes'] == interval
        report = check_last_job(schedule, cmd)
        last_run_at = Time.now - (interval * 60)
        url = gen_url(last_run_at,cmd)

        # Job didn't run
        if report['error']
          message = %(#cron WARNING expected run of #{cmd} started #{last_run_at} on ##{Socket.gethostname} not found!)
        end

        # Job still running / bombed
        if report['starttime']
          message = %(#cron WARNING #{cmd} started #{report['starttime']} on ##{Socket.gethostname} not completed in expected timeframe! #{url}) unless report['endtime']
        end

        # Job produced error messages
        if report['stderr']
          message = %(#cron NOTICE #{cmd} started #{report['starttime']} on ##{Socket.gethostname} completed with stderr #{url}) if report['stderr'].any?
        end

        Eventasaurus::publish(@ident,message) if message && @publish

      end

      # Run job if the time is now & publish result
      if cs.is_specification_in_effect?(Time.now.utc) 
        job = Jcron::Runjob.new(@server)
        result = job.run(cmd)

        message = %(#cron OK #{cmd} started #{result['starttime']} finished in #{result['runtime']} on ##{Socket.gethostname} #{gen_url(Time.now,cmd)})

        if result['exitcode']
          message = %(#cron ERROR #{cmd} started #{result['starttime']} on ##{Socket.gethostname} exited with status #{result['exitcode']}! #{url}) unless result['exitcode'] == 0
        end    

        Eventasaurus::publish(@ident,message) if @publish

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
    
  
  end
end
