# frozen_string_literal: true

module ArraySort
  # Pancake sort: sorts using only "flips", which reverse a prefix of the array, like a spatula flipping the top of a
  # stack of pancakes.
  #
  # For each position from the end, flip the largest remaining element to the front, then flip it down into place.
  # That takes at most 2n flips.
  #
  # @api private
  module PancakeSort
    module_function

    def call(array, compare)
      (array.length - 1).downto(1) do |last|
        largest = 0
        (1..last).each { |i| largest = i if compare.call(array[i], array[largest]).positive? }
        next if largest == last

        flip(array, largest) unless largest.zero?
        flip(array, last)
      end
      array
    end

    # Reverses +array[0..last]+.
    def flip(array, last)
      first = 0
      while first < last
        array[first], array[last] = array[last], array[first]
        first += 1
        last -= 1
      end
    end
  end

  register :pancake, PancakeSort, title: 'Pancake sort', stable: false,
                                  best: 'n²', average: 'n²', worst: 'n²', space: '1'
end
