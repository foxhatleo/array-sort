# frozen_string_literal: true

module ArraySort
  # Bucket sort: spreads the elements over n buckets by where their key falls between the smallest and largest key,
  # sorts each bucket with insertion sort, then concatenates the buckets.
  #
  # Keys can be any finite real numbers (Integer, Float, Rational, BigDecimal...). When they are spread evenly most
  # buckets hold one or two elements and the sort takes O(n); when they cluster, a bucket can fill up and insertion
  # sort makes it O(n²).
  #
  # @api private
  module BucketSort
    module_function

    def call(array, key)
      keys = Core.real_keys(array, key, 'bucket sort')
      count = keys.length
      return array if count < 2

      min, max = keys.minmax
      return array if min == max

      buckets = Array.new(count) { [] }
      keys.each_with_index do |k, i|
        index = (fraction(k, min, max) * (count - 1)).floor.clamp(0, count - 1)
        buckets[index] << i
      end

      elements = Array.new(array)
      position = 0
      buckets.each do |bucket|
        insertion_sort_by_key(bucket, keys)
        bucket.each do |i|
          array[position] = elements[i]
          position += 1
        end
      end
      array
    end

    # Where +k+ falls between +min+ (0.0) and +max+ (1.0). Every step only ever rounds in the same direction for larger
    # keys, so a larger key never lands in an earlier bucket.
    def fraction(k, min, max)
      span = max - min
      return (k - min).fdiv(span) if span.finite?

      # Only floats near Float::MAX get here: halving everything first keeps the arithmetic from overflowing.
      ((k / 2) - (min / 2)) / ((max / 2) - (min / 2))
    end

    # Sorts a bucket (a list of element indices) by key. Only strictly larger keys move, so the sort is stable.
    def insertion_sort_by_key(bucket, keys)
      (1...bucket.length).each do |i|
        index = bucket[i]
        j = i
        while j.positive? && keys[bucket[j - 1]] > keys[index]
          bucket[j] = bucket[j - 1]
          j -= 1
        end
        bucket[j] = index
      end
    end
  end

  register :bucket, BucketSort, title: 'Bucket sort', stable: true, kind: :distribution,
                                best: 'n', average: 'n', worst: 'n²', space: 'n'
end
