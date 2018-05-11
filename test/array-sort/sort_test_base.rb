# frozen_string_literal: true

module SortTestBase
  def self.included(base)
    base.extend ClassMethods
  end

  UNSORTED = [[7, 1], [4, 3], [1, 0], [5, 6], [2, 3], [3, 4], [7, 5], [1, 3], [3, 5], [1, 5], [2, 5], [5, 2]].freeze
  SORTED = [[1, 0], [1, 3], [1, 5], [2, 3], [2, 5], [3, 4], [3, 5], [4, 3], [5, 6], [5, 2], [7, 1], [7, 5]].freeze

  def test_empty
    assert_equal [], [].send(:"#{sort_name}_sort")
  end

  def test_one_element
    assert_equal [1], [1].send(:"#{sort_name}_sort")
  end

  def test_two_elements
    assert_equal [1, 2], [2, 1].send(:"#{sort_name}_sort")
  end

  def test_1
    assert_equal [-24, -11, 0, 1, 4, 6, 7, 10, 24, 45, 100],
                 [0, 7, 24, 45, 6, 4, -11, 100, -24, 1, 10].send(:"#{sort_name}_sort")
  end

  def test_2
    check_sorted(UNSORTED.dup.send(:"#{sort_name}_sort") { |a, b| a[0] <=> b[0] })
  end

  def test_3
    arr = UNSORTED.dup
    arr.send(:"#{sort_name}_sort") { |a, b| a[0] <=> b[0] }
    assert_equal(UNSORTED, arr)
  end

  def test_frozen
    check_sorted(UNSORTED.dup.freeze.send(:"#{sort_name}_sort") { |a, b| a[0] <=> b[0] })
  end

  def test!
    arr = UNSORTED.dup
    arr.send(:"#{sort_name}_sort!") { |a, b| a[0] <=> b[0] }
    check_sorted arr
  end

  def test_frozen!
    assert_raises FrozenError do
      UNSORTED.dup.freeze.send(:"#{sort_name}_sort!") { |a, b| a[0] <=> b[0] }
    end
  end

  def test_by
    check_sorted(UNSORTED.dup.send(:"#{sort_name}_sort_by") { |i| i[0] })
  end

  def test_by_enumerator
    enumerator = UNSORTED.dup.send(:"#{sort_name}_sort_by")
    check_sorted(enumerator.each { |i| i[0] })
  end

  def test_by_frozen
    check_sorted(UNSORTED.dup.freeze.send(:"#{sort_name}_sort_by") { |i| i[0] })
  end

  def test_by_enumerator_frozen
    enumerator = UNSORTED.dup.freeze.send(:"#{sort_name}_sort_by")
    check_sorted(enumerator.each { |i| i[0] })
  end

  def test_by!
    arr = UNSORTED.dup
    arr.send(:"#{sort_name}_sort_by!") { |i| i[0] }
    check_sorted arr
  end

  def test_by_enumerator!
    arr = UNSORTED.dup
    enumerator = arr.send(:"#{sort_name}_sort_by!")
    enumerator.each { |i| i[0] }
    check_sorted arr
  end

  def test_by_frozen!
    assert_raises FrozenError do
      arr = UNSORTED.dup.freeze
      arr.send(:"#{sort_name}_sort_by!") { |i| i[0] }
    end
  end

  def test_by_enumerator_frozen!
    assert_raises FrozenError do
      enumerator = UNSORTED.dup.freeze.send(:"#{sort_name}_sort_by!")
      enumerator.each { |i| i[0] }
    end
  end
  
  private
  
  def sort_name
    n = self.class.sort_name
    raise ArgumentError, 'No sort name has been defined.' if n.nil?
    n
  end

  def check_sorted(actual)
    if self.class.not_stable
      assert(actual.each_cons(2).all? { |a, b| (a[0] <=> b[0]) })
    elsif SORTED == actual
      assert true
    else
      self.class.not_stable = true
      puts "Sorting algorithm \"#{sort_name}\" is NOT stable!"
      check_sorted actual
    end
  end

  module ClassMethods
    attr_reader :sort_name
    attr_accessor :not_stable

    def sort_test(name)
      @sort_name = name
    end
  end

  private_constant :ClassMethods
end
