# frozen_string_literal: true

module ArraySort
  # Counting sort: counts how many times each Integer key occurs, works out from the counts where each key's elements
  # start, then places every element directly. It never compares elements.
  #
  # Takes O(n + k) time and space, where k is the range of the keys (largest minus smallest), so it is only practical
  # when that range is small. Ranges above max(2^20, 4n) raise RangeError rather than allocating a huge table; radix
  # sort handles wide ranges.
  #
  # @api private
  module CountingSort
    MAX_RANGE = 1 << 20

    module_function

    def call(array, key)
      keys = Core.integer_keys(array, key, 'counting sort')
      return array if keys.length < 2

      min, max = keys.minmax
      range = max - min + 1
      limit = [MAX_RANGE, keys.length * 4].max
      if range > limit
        raise RangeError, "counting sort can't handle a key range of #{range} (limit #{limit}); try radix_sort instead"
      end

      # starts[k] is where the next element with key (min + k) goes.
      starts = Array.new(range, 0)
      keys.each { |k| starts[k - min] += 1 }
      total = 0
      starts.each_index do |i|
        count = starts[i]
        starts[i] = total
        total += count
      end

      elements = Array.new(array)
      elements.each_with_index do |element, i|
        slot = keys[i] - min
        array[starts[slot]] = element
        starts[slot] += 1
      end
      array
    end
  end

  register :counting, CountingSort, title: 'Counting sort', stable: true, kind: :distribution,
                                    best: 'n + k', average: 'n + k', worst: 'n + k', space: 'n + k'
end
