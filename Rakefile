#!/usr/bin/env rake
require 'rubygems'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:core) do |spec|
  spec.pattern = 'spec/*.rb'
  spec.rspec_opts = '-b'
end

task :default => :core