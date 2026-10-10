# frozen_string_literal: true

# Compares every algorithm against Ruby's native Array#sort.
#
#   bundle exec rake bench
#   SIZE=5000 SHAPE=sorted ALGORITHMS=merge,tim,quick bundle exec rake bench
#
# SHAPE is one of random (default), sorted, reversed or few (only a handful of distinct values).

require 'benchmark/ips'
require_relative '../lib/array_sort'

size = Integer(ENV.fetch('SIZE', 1_000))
shape = ENV.fetch('SHAPE', 'random')
names = ENV['ALGORITHMS']&.split(',')&.map(&:to_sym) || ArraySort.algorithms

random = Random.new(42)
input = case shape
        when 'random' then Array.new(size) { random.rand(size) }
        when 'sorted' then (1..size).to_a
        when 'reversed' then (1..size).to_a.reverse
        when 'few' then Array.new(size) { random.rand(4) }
        else abort "Unknown SHAPE #{shape.inspect}; use random, sorted, reversed or few."
        end

puts "Sorting #{size} #{shape} Integers (Ruby #{RUBY_VERSION})"
Benchmark.ips do |x|
  x.config(warmup: 0.2, time: 1)
  x.report('Array#sort (native)') { input.sort }
  names.each do |name|
    x.report("#{name}_sort") { ArraySort.public_send(:"#{name}_sort", input) }
  end
  x.compare!
end
