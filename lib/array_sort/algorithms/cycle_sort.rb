# frozen_string_literal: true

module ArraySort
  # Cycle sort: writes every element directly into its final position, following the cycles of the permutation.
  #
  # An element's final position is found by counting how many elements are smaller than it. Each element is written
  # at most once, so the number of writes is the theoretical minimum, at the cost of O(n²) comparisons.
  #
  # @api private
  module CycleSort
    module_function

    def call(array, compare)
      length = array.length
      # With a consistent comparison every element is written at most once, so the whole sort makes at most +length+
      # writes. The budget only matters for inconsistent comparisons, where it keeps the sort O(n²); running out
      # closes the current cycle by putting +item+ back at +start+, so no element is ever lost.
      writes_left = length
      (0...(length - 1)).each do |start|
        item = array[start]
        position = position_of(array, compare, item, start)
        next if position == start

        loop do
          position += 1 while position < length && compare.call(item, array[position]).zero?
          position = start if position >= length || (writes_left -= 1).negative?
          array[position], item = item, array[position]
          break if position == start

          position = position_of(array, compare, item, start)
        end
      end
      array
    end

    # Returns where +item+ belongs: +start+ plus the number of elements after +start+ that are smaller than it.
    def position_of(array, compare, item, start)
      position = start
      ((start + 1)...array.length).each { |i| position += 1 if compare.call(array[i], item).negative? }
      position
    end
  end

  register :cycle, CycleSort, title: 'Cycle sort', stable: false,
                              best: 'n²', average: 'n²', worst: 'n²', space: '1'
end
