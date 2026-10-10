# frozen_string_literal: true

module ArraySort
  # Merge sort: sorts each half, then merges the two sorted halves.
  #
  # Top-down: sort each half recursively, then merge them. Merging copies the left half into a scratch buffer that
  # is allocated once for the whole sort and writes the merged run back into the array. If the two halves are already
  # in order the merge is skipped, so sorted input costs only O(n) comparisons.
  #
  # @api private
  module MergeSort
    module_function

    def call(array, compare)
      sort_range(array, compare, 0, array.length, Array.new(array.length))
      array
    end

    # Sorts +array[low...high]+.
    def sort_range(array, compare, low, high, buffer)
      return if high - low < 2

      mid = (low + high) / 2
      sort_range(array, compare, low, mid, buffer)
      sort_range(array, compare, mid, high, buffer)
      merge(array, compare, low, mid, high, buffer) if compare.call(array[mid - 1], array[mid]).positive?
    end

    # Merges the sorted runs +array[low...mid]+ and +array[mid...high]+. On ties the left element wins, which is what
    # makes the sort stable.
    def merge(array, compare, low, mid, high, buffer)
      (low...mid).each { |i| buffer[i] = array[i] }
      left = low
      right = mid
      out = low
      while left < mid && right < high
        if compare.call(buffer[left], array[right]).positive?
          array[out] = array[right]
          right += 1
        else
          array[out] = buffer[left]
          left += 1
        end
        out += 1
      end
      # Anything left over on the right is already in place; only leftovers from the left need copying back.
      while left < mid
        array[out] = buffer[left]
        left += 1
        out += 1
      end
    end
  end

  register :merge, MergeSort, title: 'Merge sort', stable: true,
                              best: 'n', average: 'n log n', worst: 'n log n', space: 'n'
end
