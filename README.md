# Jcron

Cron is great at what it does. However, it's reporting sucks. I want to know things about my crobjobs:

 - Did they run?
 - How long did they take to run?
 - Did they finish successfully?
 - Did they run in the expected timeframe?

Then, I want to be able to get event notifications for these situations, have a searchable history AND NOT HAVE LOADS OF STUPID EMAILS THAT MAKE YOUR EYES GLAZE OVER, CAUSING YOU TO MISS THE PROBLEM EVENT!

Jcron attempts to help with this, by providing a reporting framework for your cronjobs. It is expected to be run from system cron every minute, and it has it's own jcrontab file which specifies the jobs it will run. Details of the job are written to a couchdb database. Jobs are checked and reported on after they are expected to have finished. Successful runs and problems can be reported via eventasaurus: https://github.com/johanek/eventasaurus

## Other tools in this space

There may be more, these are the ones I found most interesting:

*norc* - https://github.com/darrellsilver/norc

norc is more than cron - it distributes jobs over multiple hosts, has tasks, jobs, dependencies and queues... To me it's more of a distributed job processing/queueing system than a cron replacement. It is a more complicated tool than I require.

*cronologger* - https://github.com/vvuksan/cronologger

jcron is much inspired by cronologger. However, cronologger only provides reporting, jcron also adds checks that your job started, that the job completed in expected timeframes and push notifications. And isn't written in bash.


## Installation

    $ gem install jcron

Setup couchdb instance.

Create couchdb database and create views. This can be done with the install/setup-db.rb script. Configure your database server, name and port at the top of the file.

Create a config at /etc/jcron.yaml - an example is provided at etc/jcron.yaml

  dbserver: couchdb
  dbport: 5984
  database: cron
  publish: true
  cronfile: /etc/jcrontab
  
These options are all straightforward, no? Eventasaurus is required for publishing events.

Create your jcrontab at /etc/jcrontab. See the example in etc/jcrontab - this looks the same as a normal crontab file, BUT there is a 6th field that specifies how long the command should take to run (or rather, when you want to check up on the job) and setting environment variables is not supported.

  #
  # Jcrontab accepts the following crontab syntax:
  #
  # Note the extra (6th) field! This is for the reporting function, to confirm the
  # last job run successfully
  #
  # Entry                  Description     Equivalent To
  # @yearly (or @annually) Run once a year   0 0 1 1 *
  # @monthly               Run once a month  0 0 1 * *
  # @weekly                Run once a week   0 0 * * 0
  # @daily (or @midnight)  Run once a day    0 0 * * *
  # @hourly                Run once an hour  0 * * * *
  # 
  # *    *    *    *    *    *  [user] [command]    
  # -    -    -    -    -    -
  # |    |    |    |    |    |
  # |    |    |    |    |    |
  # |    |    |    |    |    +--- expected runtime mins (Default: 60m/frequency)
  # |    |    |    |    +-------- day of week (0 - 6) (Sunday=0)
  # |    |    |    +------------- month (1 - 12)
  # |    |    +------------------ day of month (1 - 31)
  # |    +----------------------- hour (0 - 23)
  # +---------------------------- min (0 - 59)

  ###############################################################################
  #                BEWARE: ALL TIMES IN JCRONTAB ARE UTC TIMES                  #
  #              Elsewhere, reports and IDs include the timezone                #
  ###############################################################################
  
Finally, set jcron to run every minute from within your system cron config.

## Usage

Add your required jobs to /etc/jcrontab. 

View status and output from your jobs from your couchdb server. Links to the couchdb document for a job are provided in published messages.

Create web pages/tools to query job status.

TODO: Write up jcron-report once progressed

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
6. Tell me how poor my code is
