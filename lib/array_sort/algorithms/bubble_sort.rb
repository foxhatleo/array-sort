# frozen_string_literal: true

module ArraySort
  # Bubble sort: repeatedly walks the array swapping adjacent elements that are out of order.
  #
  # Each pass remembers where its last swap happened; everything after that point is already in place, so the next
  # pass stops there. An already-sorted array therefore takes a single pass.
  #
  # @api private
  module BubbleSort
    module_function

    def call(array, compare)
      unsorted_length = array.length
      while unsorted_length > 1
        last_swap = 0
        (1...unsorted_length).each do |i|
          next unless compare.call(array[i - 1], array[i]).positive?

          array[i - 1], array[i] = array[i], array[i - 1]
          last_swap = i
        end
        unsorted_length = last_swap
      end
      array
    end
  end

  register :bubble, BubbleSort, title: 'Bubble sort', stable: true,
                                best: 'n', average: 'n²', worst: 'n²', space: '1'
end
