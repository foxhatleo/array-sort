# frozen_string_literal: true

require 'test_helper'
require_relative 'sort_test_base'

class InsertionSortTest < Minitest::Test
  include SortTestBase
  sort_test 'insertion'
end
