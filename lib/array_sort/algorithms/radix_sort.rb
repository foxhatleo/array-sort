# frozen_string_literal: true

module ArraySort
  # Radix sort (least significant digit first): sorts Integer keys one byte at a time, starting with the lowest byte,
  # using a stable counting pass for each. It never compares elements.
  #
  # Takes one pass per byte of the widest key, i.e. O(n·w) time where w is the number of bytes needed for the range
  # of the keys. Negative keys work because every key is measured from the smallest one.
  #
  # @api private
  module RadixSort
    DIGIT_BITS = 8
    BASE = 1 << DIGIT_BITS
    DIGIT_MASK = BASE - 1

    module_function

    def call(array, key)
      keys = Core.integer_keys(array, key, 'radix sort')
      return array if keys.length < 2

      min = keys.min
      keys.map! { |k| k - min } # now every key is >= 0
      max = keys.max
      shift = 0
      while (max >> shift).positive?
        keys = counting_pass(array, keys, shift)
        shift += DIGIT_BITS
      end
      array
    end

    # Stably reorders +array+ (and returns +keys+ in the new order) by the digit of each key at bit offset +shift+.
    def counting_pass(array, keys, shift)
      starts = Array.new(BASE, 0)
      keys.each { |k| starts[(k >> shift) & DIGIT_MASK] += 1 }
      total = 0
      starts.each_index do |digit|
        count = starts[digit]
        starts[digit] = total
        total += count
      end

      elements = Array.new(array)
      reordered_keys = Array.new(keys.length)
      keys.each_with_index do |k, i|
        digit = (k >> shift) & DIGIT_MASK
        array[starts[digit]] = elements[i]
        reordered_keys[starts[digit]] = k
        starts[digit] += 1
      end
      reordered_keys
    end
  end

  register :radix, RadixSort, title: 'Radix sort (LSD)', stable: true, kind: :distribution,
                              best: 'n·w', average: 'n·w', worst: 'n·w', space: 'n'
end
