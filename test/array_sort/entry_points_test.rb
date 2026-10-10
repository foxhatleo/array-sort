# frozen_string_literal: true

require 'test_helper'
require 'open3'
require 'tempfile'
require 'rbconfig'

# The test process itself has loaded array/sort (which patches Array), so each case here runs in a fresh Ruby.
class EntryPointsTest < Minitest::Test
  LIB = File.expand_path('../../lib', __dir__)

  def test_array_sort_does_not_patch_array
    assert_equal 'false [1, 2, 3]', run_ruby(<<~RUBY)
      require 'array_sort'
      print [].respond_to?(:merge_sort), ' ', ArraySort.merge_sort([3, 1, 2]).inspect
    RUBY
  end

  def test_array_sort_module_functions
    assert_equal '[3, 2, 1] [1, 2, 3] ["a", "bb"] 2', run_ruby(<<~RUBY)
      require 'array_sort'
      array = [3, 1, 2]
      ArraySort.tim_sort!(array)
      print ArraySort.heap_sort([1, 3, 2]) { |a, b| b <=> a }.inspect, ' ', array.inspect, ' ',
            ArraySort.radix_sort_by(%w[bb a], &:size).inspect, ' ', ArraySort.quick_sort_by([1, 2]).size
    RUBY
  end

  def test_refinements_are_scoped_to_the_file
    Tempfile.create(['without_using', '.rb']) do |other_file|
      other_file.write("def unrefined_sort = [2, 1].merge_sort\n")
      other_file.flush

      assert_equal '[1, 2, 3] [1, 2] [2, 1] NoMethodError', run_ruby(<<~RUBY)
        require 'array_sort'
        using ArraySort::Refinements
        require #{other_file.path.inspect}
        print [3, 1, 2].merge_sort.inspect, ' ', [2, 1].quick_sort_by.each { |x| x }.inspect, ' ',
              [1, 2].swap(0, 1).inspect, ' '
        begin
          unrefined_sort
        rescue NoMethodError => e
          print e.class
        end
      RUBY
    end
  end

  def test_refinements_cover_every_method
    assert_equal 'true', run_ruby(<<~RUBY)
      require 'array_sort'
      using ArraySort::Refinements
      print ArraySort.algorithms.all? { |name|
        [[3, 1, 2].public_send(:"\#{name}_sort"), [3, 1, 2].public_send(:"\#{name}_sort!"),
         [3, 1, 2].public_send(:"\#{name}_sort_by") { |x| x }, [3, 1, 2].public_send(:"\#{name}_sort_by!") { |x| x }]
          .all?([1, 2, 3])
      }
    RUBY
  end

  def test_array_slash_sort_patches_array
    assert_equal '[1, 2, 3] true', run_ruby(<<~RUBY)
      require 'array/sort'
      print [3, 1, 2].merge_sort.inspect, ' ', Array.include?(ArraySort::ArrayMethods)
    RUBY
  end

  def test_requiring_both_is_harmless
    assert_equal '[1, 2]', run_ruby(<<~RUBY)
      require 'array_sort'
      require 'array/sort'
      require 'array_sort'
      print [2, 1].smooth_sort.inspect
    RUBY
  end

  private

  def run_ruby(script)
    output, status = Open3.capture2e(RbConfig.ruby, '-I', LIB, '-e', script)

    assert_predicate status, :success?, output
    output
  end
end
