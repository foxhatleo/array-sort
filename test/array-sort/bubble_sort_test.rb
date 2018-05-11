# frozen_string_literal: true

require 'test_helper'
require_relative 'sort_test_base'

class SortTest < Minitest::Test
  include SortTestBase
  sort_test 'bubble'
end
