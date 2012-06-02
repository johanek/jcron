# Jcron

Cron is great at what it does. However, it's reporting sucks. I want to know things about my crobjobs:

 - Did they run?
 - How long did they take to run?
 - Did they finish successfully?
 - Did they run in the expected timeframe?

Then, I want to be able to get event notifications for these situations, have a searchable history AND NOT HAVE LOADS OF STUPID EMAILS THAT YOU GLAZE OVER, CAUSING YOU TO MISS THE PROBLEM EVENT!

Jcron attempts to solve this, by providing a reporting framework for your cronjobs. It is expected to be run from system cron every minute, and it has it's own jcrontab file which specifies the jobs it will run. Details of the job are written to a couchdb database. Jobs are checked and reported on after they are expected to have finished. Successful runs and problems are reported via eventasaurus: https://github.com/johanek/eventasaurus

## Installation

    $ gem install jcron

Setup couchdb instance. TODO: Currently needs to be available on hostname couchdb

Create couchdb database and create views. TODO: Complete script for this

## Usage

TODO: Write usage instructions here

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
