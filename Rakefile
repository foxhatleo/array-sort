# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'minitest/test_task'
require 'rubocop/rake_task'

Minitest::TestTask.create

RuboCop::RakeTask.new

desc 'Validate the RBS type signatures in sig/'
task :rbs do
  require 'rbs'
  require 'rbs/cli'
  RBS::CLI.new(stdout: $stdout, stderr: $stderr).run(%w[-I sig validate])
end

desc 'Regenerate sig/array_sort.rbs from the algorithm registry'
task :sig do
  ruby 'script/generate_sig.rb'
end

desc 'Benchmark every algorithm against Array#sort (see bench/sort_benchmark.rb for options)'
task :bench do
  ruby 'bench/sort_benchmark.rb'
end

task default: %i[test rubocop rbs]
