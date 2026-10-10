# frozen_string_literal: true

# Shared tests for the sorting algorithms. algorithms_test.rb generates one test class per registered algorithm and
# includes CommonSortTests plus ComparisonSortTests or DistributionSortTests, depending on the algorithm's kind.

# Tests every algorithm has to pass. They only use Integer elements, or pairs sorted by an Integer key, so that
# distribution sorts can run them too.
module CommonSortTests
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    attr_reader :algorithm

    def sort_test(name)
      @algorithm = ArraySort.algorithm(name)
    end

    # Quadratic algorithms get smaller inputs in the large-input tests.
    def quadratic?
      algorithm.average.include?('²')
    end
  end

  # Pairs to be sorted by their first element. Several share a first element, so the result shows whether the sort is
  # stable: a stable sort must keep those in their original relative order, as in SORTED.
  UNSORTED = [[7, 1], [4, 3], [1, 0], [5, 6], [2, 3], [3, 4], [7, 5], [1, 3], [3, 5], [1, 5], [2, 5], [5, 2]].freeze
  SORTED = [[1, 0], [1, 3], [1, 5], [2, 3], [2, 5], [3, 4], [3, 5], [4, 3], [5, 6], [5, 2], [7, 1], [7, 5]].freeze
  FIRST = ->(pair) { pair[0] }

  # --- Basics ----------------------------------------------------------------------------------------------------

  def test_empty
    assert_equal [], sort([])
  end

  def test_one_element
    assert_equal [1], sort([1])
  end

  def test_two_elements
    assert_equal [1, 2], sort([2, 1])
  end

  def test_integers
    assert_equal [-24, -11, 0, 1, 4, 6, 7, 10, 24, 45, 100], sort([0, 7, 24, 45, 6, 4, -11, 100, -24, 1, 10])
  end

  def test_all_equal
    assert_equal [3] * 20, sort([3] * 20)
  end

  # --- Return values and mutation --------------------------------------------------------------------------------

  def test_does_not_modify_receiver
    array = UNSORTED.dup
    sort(array, '_by', &FIRST)

    assert_equal UNSORTED, array
  end

  def test_returns_a_new_plain_array
    subclass = Class.new(Array)
    array = subclass.new([2, 1])
    result = sort(array)

    refute_same array, result
    assert_instance_of Array, result
  end

  def test_frozen
    assert_equal [1, 2, 3], sort([3, 1, 2].freeze)
  end

  def test_bang
    array = [3, 1, 2]

    assert_same array, sort(array, '!')
    assert_equal [1, 2, 3], array
  end

  def test_bang_frozen
    assert_raises(FrozenError) { sort([3, 1, 2].freeze, '!') }
  end

  def test_bang_frozen_even_when_already_sorted
    assert_raises(FrozenError) { sort([1, 2, 3].freeze, '!') }
  end

  def test_bang_frozen_fails_before_calling_the_block
    called = false
    assert_raises(FrozenError) { sort([2, 1].freeze, '_by!') { called = true } }

    refute called, 'the block should not run when the receiver is frozen'
  end

  def test_by_bang_leaves_receiver_untouched_when_block_raises
    array = [5, 4, 3, 2, 1]
    calls = 0
    assert_raises(RuntimeError) do
      sort(array, '_by!') do |i|
        raise 'boom' if (calls += 1) > 3

        i
      end
    end

    assert_equal [5, 4, 3, 2, 1], array
  end

  # --- _by variants ----------------------------------------------------------------------------------------------

  def test_by
    assert_sorted_by_first sort(UNSORTED, '_by', &FIRST)
  end

  def test_by_calls_block_once_per_element
    calls = 0
    sort((1..100).to_a.reverse, '_by') do |i|
      calls += 1
      i
    end

    assert_equal 100, calls
  end

  def test_by_enumerator
    enumerator = sort(UNSORTED, '_by')

    assert_instance_of Enumerator, enumerator
    assert_equal UNSORTED.size, enumerator.size
    assert_sorted_by_first(enumerator.each(&FIRST))
  end

  def test_by_frozen
    assert_sorted_by_first sort(UNSORTED.dup.freeze, '_by', &FIRST)
  end

  def test_by_enumerator_frozen
    assert_sorted_by_first sort(UNSORTED.dup.freeze, '_by').each(&FIRST)
  end

  def test_by_bang
    array = UNSORTED.dup

    assert_same array, sort(array, '_by!', &FIRST)
    assert_sorted_by_first array
  end

  def test_by_enumerator_bang
    array = UNSORTED.dup
    sort(array, '_by!').each(&FIRST)

    assert_sorted_by_first array
  end

  def test_by_frozen_bang
    assert_raises(FrozenError) { sort(UNSORTED.dup.freeze, '_by!', &FIRST) }
  end

  def test_by_enumerator_frozen_bang
    enumerator = sort(UNSORTED.dup.freeze, '_by!')

    assert_raises(FrozenError) { enumerator.each(&FIRST) }
  end

  # --- Agreement with Array#sort ---------------------------------------------------------------------------------

  def test_matches_native_sort_on_random_input
    random = Random.new(42)
    200.times do
      input = Array.new(random.rand(0..80)) { random.rand(-20..20) }

      assert_equal input.sort, sort(input), "input: #{input.inspect}"
    end
  end

  def test_stability_on_random_input
    random = Random.new(7)
    200.times do
      input = Array.new(random.rand(0..80)) { |i| [random.rand(0..5), i] }

      assert_sorted_by_first sort(input, '_by', &FIRST), input
    end
  end

  def test_large_inputs_of_various_shapes
    size = self.class.quadratic? ? 600 : 10_000
    random = Random.new(3)
    shapes = {
      ascending: (1..size).to_a,
      descending: (1..size).to_a.reverse,
      organ_pipe: (1..(size / 2)).to_a + (1..(size / 2)).to_a.reverse,
      runs: Array.new(size / 40) { Array.new(40) { random.rand(size) }.sort }.flatten,
      few_distinct: Array.new(size) { random.rand(4) },
      random: Array.new(size) { random.rand(size) }
    }

    shapes.each do |shape, input|
      assert_equal input.sort, sort(input), "wrong result on #{shape} input"
    end
  end

  private

  # Calls e.g. +merge_sort+, +merge_sort!+, +merge_sort_by+ or +merge_sort_by!+ on +array+.
  def sort(array, suffix = '', &)
    array.public_send(:"#{self.class.algorithm.name}_sort#{suffix}", &)
  end

  # Asserts that +actual+ is +original+ sorted by first element. Stable algorithms must also keep elements with equal
  # first elements in their original order; for unstable ones, any order among those is accepted.
  def assert_sorted_by_first(actual, original = UNSORTED)
    if self.class.algorithm.stable?
      expected = original.equal?(UNSORTED) ? SORTED : original.sort_by.with_index { |pair, i| [pair[0], i] }

      assert_equal expected, actual
    else
      assert_equal original.sort, actual.sort, 'result must be a permutation of the input'
      assert actual.each_cons(2).all? { |a, b| a[0] <= b[0] }, "not sorted: #{actual.inspect}"
    end
  end
end

# Tests for algorithms that sort by comparing elements, and so accept a comparison block and any comparable elements.
module ComparisonSortTests
  BY_FIRST = ->(a, b) { a[0] <=> b[0] }

  def test_strings
    assert_equal %w[apple banana cherry date], sort(%w[date apple cherry banana])
  end

  def test_floats
    assert_equal [-1.5, 0.0, 0.25, 3.0], sort([3.0, 0.25, -1.5, 0.0])
  end

  def test_large_integers
    big = 2**70

    assert_equal [-big, -1, 0, big, big + 1], sort([big + 1, 0, -big, big, -1])
  end

  def test_block
    assert_sorted_by_first sort(CommonSortTests::UNSORTED, &BY_FIRST)
  end

  def test_bang_with_block
    array = CommonSortTests::UNSORTED.dup

    assert_same array, sort(array, '!', &BY_FIRST)
    assert_sorted_by_first array
  end

  def test_descending_block
    assert_equal [9, 6, 5, 4, 3, 2, 1, 1], sort([3, 1, 4, 1, 5, 9, 2, 6]) { |a, b| b <=> a }
  end

  def test_descending_block_on_large_input
    input = Array.new(500) { |i| (i * 7919) % 1000 }

    assert_equal input.sort.reverse, sort(input) { |a, b| b <=> a }
  end

  def test_block_returning_any_magnitude
    assert_equal [1, 1, 2, 3, 4, 5, 6, 9], sort([3, 1, 4, 1, 5, 9, 2, 6]) { |a, b| (a - b) * 10 }
  end

  def test_block_returning_floats
    assert_equal [1, 1, 2, 3, 4, 5, 6, 9], sort([3, 1, 4, 1, 5, 9, 2, 6]) { |a, b| (a - b) / 2.0 }
  end

  def test_incomparable_elements
    error = assert_raises(ArgumentError) { sort([3, 'a', 1]) }
    assert_match(/comparison of .+ with .+ failed/, error.message)
  end

  def test_block_returning_nil
    assert_raises(ArgumentError) { sort([3, 1, 2]) { nil } }
  end

  def test_by_incomparable_keys
    error = assert_raises(ArgumentError) { sort([1, 2, 3], '_by') { |i| i.odd? ? i : i.to_s } }
    assert_match(/comparison of (Integer with String|String with Integer) failed/, error.message)
  end

  def test_by_string_keys
    assert_equal %w[a bb ccc], sort(%w[ccc a bb], '_by', &:itself)
  end

  # Long enough to reach the merge phase of Timsort, which only starts at 64 elements.
  def test_inconsistent_block_terminates
    input = (1..300).to_a.shuffle(random: Random.new(1))
    random = Random.new(2)

    [proc { 1 }, proc { -1 }, proc { 0 }, proc { random.rand(-1..1) }].each do |block|
      assert_equal input.sort, sort(input, &block).sort, 'result must be a permutation of the input'
    end
  end

  def test_bang_leaves_receiver_untouched_when_comparison_raises
    array = [5, 4, 3, 2, 1]
    calls = 0
    assert_raises(RuntimeError) do
      sort(array, '!') do |a, b|
        raise 'boom' if (calls += 1) > 3

        a <=> b
      end
    end

    assert_equal [5, 4, 3, 2, 1], array
  end

  def test_bang_with_block_frozen_fails_before_calling_the_block
    called = false
    assert_raises(FrozenError) { sort([2, 1].freeze, '!') { called = true } }

    refute called
  end

  # Guards against an O(n log n) algorithm silently degrading to O(n²) on structured input. The constant factors are
  # generous (introsort, for one, spends about 3 n log n comparisons on organ-pipe input, where its heap sort fallback
  # kicks in), but still far below what a quadratic algorithm would need.
  def test_comparison_count_within_complexity_bound
    size = self.class.quadratic? ? 300 : 5_000
    limit = self.class.quadratic? ? 2 * size * size : 4 * size * Math.log2(size)
    random = Random.new(3)
    inputs = {
      sorted: (1..size).to_a,
      reversed: (1..size).to_a.reverse,
      organ_pipe: (1..(size / 2)).to_a + (1..(size / 2)).to_a.reverse,
      random: (1..size).to_a.shuffle(random: random)
    }

    inputs.each do |shape, input|
      comparisons = 0
      sort(input) do |a, b|
        comparisons += 1
        a <=> b
      end

      assert_operator comparisons, :<=, limit, "too many comparisons on #{shape} input"
    end
  end
end

# Tests for algorithms that distribute elements by numeric key instead of comparing them.
module DistributionSortTests
  def test_rejects_comparison_block
    error = assert_raises(ArgumentError) { sort([2, 1]) { |a, b| a <=> b } }
    assert_match(/_sort_by/, error.message)
  end

  def test_bang_rejects_comparison_block
    array = [2, 1]
    assert_raises(ArgumentError) { sort(array, '!') { |a, b| a <=> b } }

    assert_equal [2, 1], array
  end

  def test_rejects_non_numeric_elements
    assert_raises(ArgumentError) { sort(%w[b a]) }
    assert_raises(ArgumentError) { sort([1, nil]) }
  end

  def test_rejects_non_numeric_keys
    assert_raises(ArgumentError) { sort(%w[b a], '_by', &:itself) }
  end

  def test_by_string_lengths
    assert_equal %w[a bb ccc], sort(%w[ccc a bb], '_by', &:length)
  end
end
