require "bundler/gem_tasks"
require 'rake/testtask'

require File.expand_path(File.dirname(__FILE__)) + "/test/config"
require File.expand_path(File.dirname(__FILE__)) + "/test/support/config"

desc 'Run mysql2 tests by default'
task :default => :test

desc 'Run mysql2 tests'
task :test => :test_mysql2

desc 'Build MySQL test databases'
namespace :db do
  task :create => ['db:mysql:build']
  task :drop => ['db:mysql:drop']
end

%w( mysql mysql2 ).each do |adapter|
  namespace :test do
    Rake::TestTask.new(adapter => "#{adapter}:env") { |t|
      t.libs << 'test'
      t.test_files = Dir.glob( "test/cases/**/*_test.rb" ).sort

      t.warning = true
      t.verbose = true
    }
  end

  namespace adapter do
    task :test => "test_#{adapter}"

    # Set the connection environment for the adapter
    task(:env) { ENV['ARCONN'] = adapter }
  end

  # Make sure the adapter test evaluates the env setting task
  task "test_#{adapter}" => ["#{adapter}:env", "test:#{adapter}"]
end

namespace :db do
  namespace :mysql do
    desc 'Build the MySQL test databases'
    task :build do
      config = ARTest.config['connections']['mysql']
      %x( mysql --user=#{config['arunit']['username']} -e "create DATABASE #{config['arunit']['database']} DEFAULT CHARACTER SET utf8" )
    end

    desc 'Drop the MySQL test databases'
    task :drop do
      config = ARTest.config['connections']['mysql']
      %x( mysqladmin --user=#{config['arunit']['username']} -f drop #{config['arunit']['database']} )
    end

    desc 'Rebuild the MySQL test databases'
    task :rebuild => [:drop, :build]
  end
end

task :build_mysql_databases => 'db:mysql:build'
task :drop_mysql_databases => 'db:mysql:drop'
task :rebuild_mysql_databases => 'db:mysql:rebuild'
