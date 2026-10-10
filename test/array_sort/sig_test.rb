# frozen_string_literal: true

require 'test_helper'
require_relative '../../script/generate_sig'

class SigTest < Minitest::Test
  def test_signatures_are_up_to_date
    assert_equal SigGenerator.render, File.read(SigGenerator::PATH, encoding: 'UTF-8'),
                 'sig/array_sort.rbs is out of date; run `bundle exec rake sig`'
  end
end
