# frozen_string_literal: true

module ArraySort
  # Odd-even sort (brick sort): alternates between comparing every odd/even pair of neighbours and every even/odd
  # pair, swapping those that are out of order.
  #
  # All the comparisons within a phase are independent, which is why this sort is used on parallel hardware. n rounds
  # are always enough, so the loop stops there even if the comparison is inconsistent.
  #
  # @api private
  module OddEvenSort
    module_function

    def call(array, compare)
      length = array.length
      length.times do
        sorted = true
        [1, 0].each do |start|
          start.step(length - 2, 2) do |i|
            next unless compare.call(array[i], array[i + 1]).positive?

            array[i], array[i + 1] = array[i + 1], array[i]
            sorted = false
          end
        end
        break if sorted
      end
      array
    end
  end

  register :odd_even, OddEvenSort, title: 'Odd-even sort', stable: true,
                                   best: 'n', average: 'n²', worst: 'n²', space: '1'
end
