# frozen_string_literal: true

require 'test_helper'

class TraceTest < Minitest::Test
  INPUT = [5, 3, 8, 1, 9, 2, 7, 3, 0, 6, 4, 8, 2, 5, 1, 9, 7, 3, 6, 0].freeze

  # Replaying the recorded writes on a copy of the input must reproduce the sort exactly. This also checks that every
  # algorithm only changes the array through single-element assignment, which is what tracing relies on.
  def test_replaying_writes_reproduces_every_sort
    ArraySort.algorithms.each do |name|
      trace = ArraySort.trace(name, INPUT)
      replay = INPUT.dup
      trace.events.grep(ArraySort::Trace::Write).each { |write| replay[write.index] = write.value }

      assert_equal INPUT.sort, trace.result, "#{name}: wrong result"
      assert_equal trace.result, replay, "#{name}: writes don't reproduce the result"
    end
  end

  def test_counts
    trace = ArraySort.trace(:insertion, [3, 1, 2])

    assert_equal [1, 2, 3], trace.result
    assert_equal 3, trace.comparisons
    assert_equal trace.events.count { |e| e.is_a?(ArraySort::Trace::Write) }, trace.writes
    assert_equal ArraySort::Trace::Comparison.new(left: 3, right: 1, result: 1), trace.events.first
  end

  def test_distribution_sorts_make_no_comparisons
    %i[counting radix bucket].each do |name|
      assert_equal 0, ArraySort.trace(name, INPUT).comparisons, name
    end
  end

  def test_cycle_sort_writes_each_element_at_most_once
    trace = ArraySort.trace(:cycle, INPUT)

    assert_operator trace.writes, :<=, INPUT.length
  end

  def test_streams_events_to_the_block
    streamed = []
    trace = ArraySort.trace(:heap, INPUT) { |event| streamed << event }

    assert_equal trace.events, streamed
  end

  def test_does_not_modify_input
    input = INPUT.dup
    trace = ArraySort.trace(:quick, input)

    assert_equal INPUT, input
    assert_equal INPUT, trace.input
    assert_predicate trace.input, :frozen?
    assert_equal :quick, trace.algorithm.name
  end

  def test_unknown_algorithm
    assert_raises(ArgumentError) { ArraySort.trace(:bogo, [1]) }
  end
end
