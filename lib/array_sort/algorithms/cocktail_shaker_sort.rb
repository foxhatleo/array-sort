# frozen_string_literal: true

module ArraySort
  # Cocktail shaker sort: bubble sort that alternates direction, carrying the largest element to the end on the way
  # up and the smallest to the front on the way down.
  #
  # Moving in both directions fixes bubble sort's "turtles" (small elements near the end, which bubble sort moves only
  # one step per pass). Each pass also narrows the unsorted range to where its last swap happened.
  #
  # @api private
  module CocktailShakerSort
    module_function

    def call(array, compare)
      low = 0
      high = array.length - 1
      while low < high
        last_swap = low
        (low...high).each do |i|
          next unless compare.call(array[i], array[i + 1]).positive?

          array[i], array[i + 1] = array[i + 1], array[i]
          last_swap = i
        end
        high = last_swap

        last_swap = high
        (high - 1).downto(low) do |i|
          next unless compare.call(array[i], array[i + 1]).positive?

          array[i], array[i + 1] = array[i + 1], array[i]
          last_swap = i + 1
        end
        low = last_swap
      end
      array
    end
  end

  register :cocktail_shaker, CocktailShakerSort, title: 'Cocktail shaker sort', stable: true,
                                                 best: 'n', average: 'n²', worst: 'n²', space: '1'
end
