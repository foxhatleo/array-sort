# frozen_string_literal: true

module ArraySort
  # The methods ArraySort adds to arrays. +require 'array/sort'+ includes this module into +Array+; +using
  # ArraySort::Refinements+ adds the same methods to +Array+ in one file only.
  #
  # For every algorithm name +x+ in {ArraySort.algorithms} there are four methods with the same contract as their
  # native counterparts:
  #
  # [+x_sort(&block)+]     Returns a new sorted array. Comparison sorts accept an optional comparison block.
  # [+x_sort!(&block)+]    Sorts +self+ in place and returns it.
  # [+x_sort_by(&block)+]  Returns a new array sorted by the keys the block returns, calling the block once per
  #                        element. Returns an Enumerator without a block.
  # [+x_sort_by!(&block)+] Sorts +self+ in place by the keys the block returns. Returns an Enumerator without a block.
  #
  # Distribution sorts (counting, radix and bucket sort) don't compare elements, so +x_sort+ and +x_sort!+ raise
  # ArgumentError when given a block, and every element (or key, for the +_by+ methods) must be an Integer (or for
  # bucket sort, any finite real number).
  #
  # See {ArraySort.algorithm} for each algorithm's stability and complexity.
  module ArrayMethods
    # Swap two elements in the array, and returns +self+.
    #
    # Negative indices count from the end of the array, as with +Array#[]+.
    #
    # @param index1 [Integer] The index of the first element.
    # @param index2 [Integer] The index of the second element.
    # @return [Array] +self+
    # @raise [ArgumentError] If either of the two parameters is not an Integer.
    # @raise [IndexError] If either index is outside the bounds of the array.
    def swap(index1, index2)
      raise ArgumentError, 'Index must be an integer.' unless index1.is_a?(Integer) && index2.is_a?(Integer)

      fetch(index1)
      fetch(index2)
      self[index1], self[index2] = self[index2], self[index1] if index1 != index2
      self
    end

    # The methods are compiled from source rather than created with define_method so that Refinements can import
    # them (Refinement#import_methods only accepts methods written in Ruby source). For +name = :merge+ this defines
    # merge_sort, merge_sort!, merge_sort_by and merge_sort_by!.
    ArraySort.algorithms.each do |name|
      module_eval <<~RUBY, __FILE__, __LINE__ + 1 # rubocop:disable Style/DocumentDynamicEvalDefinition
        def #{name}_sort(&)
          ArraySort::Core.sort(self, :#{name}, &)
        end

        def #{name}_sort!(&)
          ArraySort::Core.sort!(self, :#{name}, &)
        end

        def #{name}_sort_by(&)
          return ArraySort::Core.sort_by_enumerator(self, :#{name}, bang: false) unless block_given?

          ArraySort::Core.sort_by(self, :#{name}, &)
        end

        def #{name}_sort_by!(&)
          return ArraySort::Core.sort_by_enumerator(self, :#{name}, bang: true) unless block_given?

          ArraySort::Core.sort_by!(self, :#{name}, &)
        end
      RUBY
    end
  end
end
