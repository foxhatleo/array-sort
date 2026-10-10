# frozen_string_literal: true

module ArraySort
  # Comb sort: bubble sort that first compares elements far apart, shrinking the gap by a factor of 1.3 each pass.
  #
  # The long-range passes move small elements near the end ("turtles") forward quickly; once the gap reaches 1, a
  # final bubble sort finishes the job on an array that is already nearly sorted.
  #
  # @api private
  module CombSort
    SHRINK_FACTOR = 1.3

    module_function

    def call(array, compare)
      gap = array.length
      loop do
        gap = (gap / SHRINK_FACTOR).floor
        break if gap <= 1

        (0...(array.length - gap)).each do |i|
          next unless compare.call(array[i], array[i + gap]).positive?

          array[i], array[i + gap] = array[i + gap], array[i]
        end
      end
      BubbleSort.call(array, compare)
    end
  end

  register :comb, CombSort, title: 'Comb sort', stable: false,
                            best: 'n log n', average: 'n²/2ᵖ', worst: 'n²', space: '1'
end
