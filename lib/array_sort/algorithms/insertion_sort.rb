# frozen_string_literal: true

module ArraySort
  # Insertion sort: grows a sorted prefix one element at a time, inserting each new element where it belongs.
  #
  # Larger elements are shifted one slot to the right until the gap reaches the correct position, which takes fewer
  # writes than swapping the element into place pair by pair. Very fast on small or nearly-sorted arrays, which is why
  # hybrid sorts like introsort use it for short ranges.
  #
  # @api private
  module InsertionSort
    module_function

    def call(array, compare)
      sort_range(array, compare, 0, array.length - 1)
      array
    end

    # Sorts +array[low..high]+.
    def sort_range(array, compare, low, high)
      ((low + 1)..high).each do |i|
        element = array[i]
        j = i
        while j > low && compare.call(array[j - 1], element).positive?
          array[j] = array[j - 1]
          j -= 1
        end
        array[j] = element unless j == i
      end
    end
  end

  register :insertion, InsertionSort, title: 'Insertion sort', stable: true,
                                      best: 'n', average: 'n²', worst: 'n²', space: '1'
end
