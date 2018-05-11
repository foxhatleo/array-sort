# frozen_string_literal: true

require 'test_helper'

class ArraySortTest < Minitest::Test
  def test_version_number
    refute_nil ::ArraySort::VERSION
  end

  def test_swap_helper_1
    array = [1, 2, 3, 4, 5]
    array.swap 0, 2
    assert_equal [3, 2, 1, 4, 5], array
  end

  def test_swap_helper_2
    object_a = Object.new
    object_b = Object.new
    object_c = Object.new
    array = [object_a, object_b, object_c]
    array.swap 0, 1
    assert_equal [object_b, object_a, object_c], array
  end

  def test_swap_helper_error_1
    assert_raises ArgumentError do
      [1, 2, 3].swap nil, 2
    end
  end

  def test_swap_helper_error_2
    assert_raises ArgumentError do
      [1, 2, 3].swap 1, 'str'
    end
  end

  def test_swap_helper_error_3
    assert_raises ArgumentError do
      [1, 2, 3].swap 1, nil
    end
  end
end
