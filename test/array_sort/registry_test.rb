# frozen_string_literal: true

require 'test_helper'

class RegistryTest < Minitest::Test
  EXPECTED = %i[
    binary_insertion bubble bucket cocktail_shaker comb counting cycle gnome heap insertion intro merge odd_even
    pancake quick radix selection shell smooth tim tournament tree
  ].freeze

  def test_algorithms
    assert_equal EXPECTED, ArraySort.algorithms
  end

  def test_algorithm
    merge = ArraySort.algorithm(:merge)

    assert_equal 'Merge sort', merge.title
    assert_predicate merge, :stable?
    assert_predicate merge, :comparison?
    refute_predicate merge, :distribution?
    assert_equal 'n log n', merge.worst
    assert_same merge, ArraySort.algorithm('merge')
  end

  def test_distribution_algorithms
    assert_equal(%i[bucket counting radix], ArraySort.algorithms.select { |n| ArraySort.algorithm(n).distribution? })
  end

  def test_unknown_algorithm
    error = assert_raises(ArgumentError) { ArraySort.algorithm(:bogo) }
    assert_match(/unknown sorting algorithm: :bogo/, error.message)
  end

  def test_register_is_private
    assert_raises(NoMethodError) { ArraySort.register(:x, Object) }
  end

  # The README's algorithm table must match the registry.
  def test_readme_table_matches_registry
    readme = File.read(File.expand_path('../../README.md', __dir__), encoding: 'UTF-8')
    ArraySort.algorithms.each do |name|
      algorithm = ArraySort.algorithm(name)
      row = [algorithm.title, "`#{name}_sort`", algorithm.best, algorithm.average, algorithm.worst,
             algorithm.space, algorithm.stable? ? 'Yes' : 'No']
      pattern = /^\| #{row.map { |cell| Regexp.escape(cell) }.join(' +\| ')} +\|$/

      refute_nil readme[pattern], "README is missing or has an outdated row for #{name}; expected:\n#{row.join(' | ')}"
    end
  end
end
