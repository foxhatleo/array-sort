# frozen_string_literal: true

module ArraySort
  # Quicksort: picks a pivot, partitions the array around it, and sorts each side.
  #
  # In place, with a randomly chosen pivot so that no particular input (sorted, reversed, organ-pipe...) reliably
  # triggers the quadratic worst case, and a three-way (Dutch national flag) partition so that runs of equal elements
  # are handled in a single pass. Only the smaller partition is sorted recursively and the larger one is handled by the
  # loop, which keeps the recursion depth at O(log n) no matter how unlucky the pivots are.
  #
  # @api private
  module QuickSort
    module_function

    def call(array, compare)
      sort_range(array, compare, 0, array.length - 1)
      array
    end

    # Sorts +array[low..high]+.
    def sort_range(array, compare, low, high)
      while low < high
        less_end, greater_start = partition(array, compare, low, high, rand(low..high))
        if less_end - low < high - greater_start
          sort_range(array, compare, low, less_end)
          low = greater_start
        else
          sort_range(array, compare, greater_start, high)
          high = less_end
        end
      end
    end

    # Rearranges +array[low..high]+ into elements less than, equal to, and greater than the pivot +array[pivot_index]+.
    # Returns the index of the last "less than" element and the first "greater than" element.
    #
    # The pivot itself always ends up in the "equal" region, so every call makes progress even if the comparison is
    # inconsistent (for example, a block that always returns 1).
    def partition(array, compare, low, high, pivot_index)
      array[low], array[pivot_index] = array[pivot_index], array[low]
      pivot = array[low]

      less = low + 1
      greater = high
      i = low + 1
      while i <= greater
        comparison = compare.call(array[i], pivot)
        if comparison.negative?
          array[less], array[i] = array[i], array[less]
          less += 1
          i += 1
        elsif comparison.positive?
          array[i], array[greater] = array[greater], array[i]
          greater -= 1
        else
          i += 1
        end
      end

      # Move the pivot from the front to the end of the "less than" region, i.e. the start of the "equal" region.
      array[low], array[less - 1] = array[less - 1], array[low]
      [less - 2, greater + 1]
    end
  end

  register :quick, QuickSort, title: 'Quicksort', stable: false,
                              best: 'n log n', average: 'n log n', worst: 'n²', space: 'log n'
end
