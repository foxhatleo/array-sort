# frozen_string_literal: true

require 'test_helper'
require_relative 'sort_test_base'

class BubbleSortTest < Minitest::Test
  include SortTestBase

  sort_test 'bubble', stable: true, quadratic: true
end
