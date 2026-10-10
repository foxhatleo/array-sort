# frozen_string_literal: true

module ArraySort
  # Selection sort: repeatedly finds the smallest remaining element and swaps it to the front.
  #
  # Always makes n(n-1)/2 comparisons, but at most n-1 swaps, so it is a reasonable choice when writes are expensive.
  #
  # @api private
  module SelectionSort
    module_function

    def call(array, compare)
      length = array.length
      (0...(length - 1)).each do |i|
        smallest = i
        ((i + 1)...length).each { |j| smallest = j if compare.call(array[j], array[smallest]).negative? }
        array[i], array[smallest] = array[smallest], array[i] unless smallest == i
      end
      array
    end
  end

  register :selection, SelectionSort, title: 'Selection sort', stable: false,
                                      best: 'n²', average: 'n²', worst: 'n²', space: '1'
end
