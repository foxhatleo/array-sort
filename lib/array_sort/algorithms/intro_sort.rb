# frozen_string_literal: true

module ArraySort
  # Introsort: quicksort that switches to heap sort if the recursion gets too deep, and to insertion sort for short
  # ranges. This is the algorithm behind C++'s std::sort.
  #
  # Quicksort is fastest in practice; the heap sort fallback caps the worst case at O(n log n), and insertion sort
  # is faster than either on a handful of elements. Sorted and reversed input partition perfectly; "organ pipe" input
  # (ascending, then descending) is a classic case where median-of-three pivots go wrong and the fallback takes over.
  #
  # @api private
  module IntroSort
    # Ranges this short are finished with insertion sort.
    SMALL_RANGE = 16

    module_function

    def call(array, compare)
      sort_range(array, compare, 0, array.length - 1, 2 * Math.log2([array.length, 1].max).floor)
      array
    end

    # Sorts +array[low..high]+, falling back to heap sort once +depth_limit+ partitions have been made.
    def sort_range(array, compare, low, high, depth_limit)
      while high - low + 1 > SMALL_RANGE
        return HeapSort.sort_range(array, compare, low, high) if depth_limit.zero?

        depth_limit -= 1
        split = partition(array, compare, low, high)
        # Recurse into the smaller side and loop on the larger one, keeping the stack shallow.
        if split - low < high - split
          sort_range(array, compare, low, split, depth_limit)
          low = split + 1
        else
          sort_range(array, compare, split + 1, high, depth_limit)
          high = split
        end
      end
      InsertionSort.sort_range(array, compare, low, high)
    end

    # Hoare partition around the median of the first, middle and last elements: rearranges +array[low..high]+ so that
    # no element of +array[low..split]+ is greater than the pivot and no element of +array[split + 1..high]+ is
    # smaller, and returns +split+.
    #
    # Unlike a three-way partition, this barely disturbs input that is already partly ordered, which keeps pivots good
    # on sorted, reversed and similar inputs. The bounds checks only matter for inconsistent comparisons, where they
    # keep both sides non-empty so that sorting still finishes.
    def partition(array, compare, low, high)
      pivot = array[median_of_three(array, compare, low, (low + high) / 2, high)]
      i = low - 1
      j = high + 1
      loop do
        i += 1
        i += 1 while i < high && compare.call(array[i], pivot).negative?
        j -= 1
        j -= 1 while j > low && compare.call(array[j], pivot).positive?
        return j.clamp(low, high - 1) if i >= j

        array[i], array[j] = array[j], array[i]
      end
    end

    # Returns whichever of the indices +a+, +b+ and +c+ holds the median of the three elements.
    def median_of_three(array, compare, a, b, c)
      if compare.call(array[a], array[b]).negative?
        return b if compare.call(array[b], array[c]).negative?

        compare.call(array[a], array[c]).negative? ? c : a
      else
        return a if compare.call(array[a], array[c]).negative?

        compare.call(array[b], array[c]).negative? ? c : b
      end
    end
  end

  register :intro, IntroSort, title: 'Introsort', stable: false,
                              best: 'n log n', average: 'n log n', worst: 'n log n', space: 'log n'
end
