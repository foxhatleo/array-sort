# frozen_string_literal: true

require 'test_helper'

class HelperTest < Minitest::Test
  def test_version_number
    assert_match(/\A\d+\.\d+\.\d+\z/, ::ArraySort::VERSION)
  end

  def test_swap
    array = [1, 2, 3, 4, 5]

    assert_same array, array.swap(0, 2)
    assert_equal [3, 2, 1, 4, 5], array
  end

  def test_swap_objects
    object_a = Object.new
    object_b = Object.new
    object_c = Object.new
    array = [object_a, object_b, object_c]
    array.swap 0, 1

    assert_equal [object_b, object_a, object_c], array
  end

  def test_swap_same_index
    assert_equal [1, 2, 3], [1, 2, 3].swap(1, 1)
  end

  def test_swap_negative_indices
    assert_equal [3, 2, 1], [1, 2, 3].swap(0, -1)
  end

  def test_swap_non_integer_index
    assert_raises(ArgumentError) { [1, 2, 3].swap nil, 2 }
    assert_raises(ArgumentError) { [1, 2, 3].swap 1, 'str' }
    assert_raises(ArgumentError) { [1, 2, 3].swap 1, nil }
  end

  def test_swap_out_of_bounds
    array = [1, 2, 3]

    assert_raises(IndexError) { array.swap 0, 3 }
    assert_raises(IndexError) { array.swap(-4, 0) }
    assert_equal [1, 2, 3], array
  end

  def test_swap_frozen
    assert_raises(FrozenError) { [1, 2, 3].freeze.swap 0, 1 }
  end

  def test_array_gains_only_public_methods
    added = Array.private_instance_methods(false) - [].method(:initialize).owner.private_instance_methods(false)

    assert_empty added.grep(/sort|heap|sift|swap|merge|clone/)
  end
end
