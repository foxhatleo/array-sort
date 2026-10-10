# frozen_string_literal: true

require 'test_helper'
require_relative 'shared_sort_tests'

# One test class per registered algorithm (MergeSortTest, TimSortTest, ...), so that every algorithm runs the shared
# tests without having to remember to add a file for it.
ArraySort.algorithms.each do |name|
  algorithm = ArraySort.algorithm(name)
  test_class = Class.new(Minitest::Test) do
    include CommonSortTests
    include algorithm.comparison? ? ComparisonSortTests : DistributionSortTests

    sort_test name
  end
  Object.const_set("#{name.to_s.split('_').map(&:capitalize).join}SortTest", test_class)
end

class CountingSortExtraTest < Minitest::Test
  def test_rejects_floats
    assert_raises(ArgumentError) { [1.5, 0.5].counting_sort }
  end

  def test_key_range_too_large
    error = assert_raises(RangeError) { [0, 2**40].counting_sort }
    assert_match(/radix_sort/, error.message)
  end

  def test_wide_range_allowed_for_long_arrays
    input = Array.new(300_000) { |i| (i * 7) % 1_100_000 }

    assert_equal input.sort, input.counting_sort
  end
end

class RadixSortExtraTest < Minitest::Test
  def test_rejects_floats
    assert_raises(ArgumentError) { [1.5, 0.5].radix_sort }
  end

  def test_huge_and_negative_keys
    input = [2**100, -(2**90), 0, (2**100) - 1, -1, 2**64, 255, 256]

    assert_equal input.sort, input.radix_sort
  end
end

class BucketSortExtraTest < Minitest::Test
  def test_floats
    assert_equal [-2.5, 0.1, 0.30000000000000004, 0.3, 7.0].sort, [0.3, 7.0, -2.5, 0.30000000000000004, 0.1].bucket_sort
  end

  def test_mixed_real_numbers
    input = [Rational(1, 3), 0.25, 1, -2, 0.5r, 2**64]

    assert_equal input.sort, input.bucket_sort
  end

  def test_extreme_floats
    input = [Float::MAX, -Float::MAX, 0.0, 5e-324, -5e-324, 1e300, -1e300]

    assert_equal input.sort, input.bucket_sort
  end

  def test_rejects_nan_and_infinity
    assert_raises(ArgumentError) { [1.0, Float::NAN].bucket_sort }
    assert_raises(ArgumentError) { [1.0, Float::INFINITY].bucket_sort }
  end

  def test_rejects_complex
    assert_raises(ArgumentError) { [Complex(1, 2), 1].bucket_sort }
  end
end
