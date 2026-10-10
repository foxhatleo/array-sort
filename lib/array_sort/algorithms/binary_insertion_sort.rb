# frozen_string_literal: true

module ArraySort
  # Binary insertion sort: insertion sort that finds each element's position with a binary search.
  #
  # Needs only O(n log n) comparisons, which helps when comparing is expensive, but still moves O(n²) elements. The
  # search finds the position after any equal elements, which keeps the sort stable.
  #
  # @api private
  module BinaryInsertionSort
    module_function

    def call(array, compare)
      (1...array.length).each do |i|
        element = array[i]
        position = upper_bound(array, compare, element, 0, i)
        next if position == i

        i.downto(position + 1) { |j| array[j] = array[j - 1] }
        array[position] = element
      end
      array
    end

    # Returns the first index in +array[low...high]+ whose element is greater than +element+.
    def upper_bound(array, compare, element, low, high)
      while low < high
        mid = (low + high) / 2
        if compare.call(element, array[mid]).negative?
          high = mid
        else
          low = mid + 1
        end
      end
      low
    end
  end

  register :binary_insertion, BinaryInsertionSort, title: 'Binary insertion sort', stable: true,
                                                   best: 'n log n', average: 'n²', worst: 'n²', space: '1'
end
