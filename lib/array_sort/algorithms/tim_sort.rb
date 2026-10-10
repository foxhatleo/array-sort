# frozen_string_literal: true

module ArraySort
  # Timsort: finds the runs that are already in order in the data, extends short runs with binary insertion sort, and
  # merges runs in a carefully balanced order. This is the algorithm behind Python's sorted() and Java's
  # Arrays.sort for objects.
  #
  # Real-world data is often partly sorted, and Timsort takes advantage of it: sorted or reverse-sorted input takes a
  # single O(n) pass. Merges "gallop" (search exponentially) when one run keeps winning, so merging runs that barely
  # overlap is cheap too.
  #
  # This follows the structure of the reference implementation, including the corrected merge invariants
  # (de Gouw et al., 2015), but always merges with a temporary copy of the left run rather than choosing the smaller
  # run, which keeps it simpler at the cost of some extra memory.
  #
  # @api private
  module TimSort
    # Arrays shorter than this are sorted with binary insertion sort alone.
    MIN_MERGE = 32
    # How many consecutive wins by one run switch a merge into galloping mode.
    MIN_GALLOP = 7

    module_function

    def call(array, compare)
      Sorter.new(array, compare).sort if array.length > 1
      array
    end

    # Holds the state of one sort: the array, the stack of pending runs and the adaptive galloping threshold.
    class Sorter
      def initialize(array, compare)
        @array = array
        @compare = compare
        @runs = [] # [start, length] pairs, waiting to be merged
        @min_gallop = MIN_GALLOP
      end

      def sort
        length = @array.length
        min_run = min_run_length(length)
        low = 0
        while low < length
          run_length = count_run_and_make_ascending(low, length)
          if run_length < min_run
            forced = [length - low, min_run].min
            binary_insertion_sort(low, low + forced, low + run_length)
            run_length = forced
          end
          @runs << [low, run_length]
          merge_collapse
          low += run_length
        end
        merge_force_collapse
      end

      private

      def less?(a, b) = @compare.call(a, b).negative?

      # A run length in (MIN_MERGE / 2)..MIN_MERGE such that length / min_run is a power of two or just below one,
      # which keeps the final merges balanced.
      def min_run_length(length)
        remainder = 0
        while length >= MIN_MERGE
          remainder |= length & 1
          length >>= 1
        end
        length + remainder
      end

      # Returns the length of the run starting at +low+, reversing it first if it is strictly descending. (Only
      # strictly descending runs are reversed, so equal elements never swap places.)
      def count_run_and_make_ascending(low, high)
        run_high = low + 1
        return 1 if run_high == high

        if less?(@array[run_high], @array[low])
          run_high += 1 while run_high < high && less?(@array[run_high], @array[run_high - 1])
          reverse_range(low, run_high - 1)
        else
          run_high += 1 while run_high < high && !less?(@array[run_high], @array[run_high - 1])
        end
        run_high - low
      end

      def reverse_range(low, high)
        while low < high
          @array[low], @array[high] = @array[high], @array[low]
          low += 1
          high -= 1
        end
      end

      # Sorts +@array[low...high]+, given that +@array[low...start]+ is already sorted.
      def binary_insertion_sort(low, high, start)
        (start...high).each do |i|
          element = @array[i]
          position = BinaryInsertionSort.upper_bound(@array, @compare, element, low, i)
          next if position == i

          i.downto(position + 1) { |j| @array[j] = @array[j - 1] }
          @array[position] = element
        end
      end

      # Merges runs at the top of the stack until these hold for the top three run lengths z, y, x:
      # z > y + x and y > x. That keeps the stack O(log n) deep and the merges balanced.
      def merge_collapse
        while @runs.size > 1
          n = @runs.size - 2
          if (n.positive? && run_length(n - 1) <= run_length(n) + run_length(n + 1)) ||
             (n > 1 && run_length(n - 2) <= run_length(n - 1) + run_length(n))
            n -= 1 if run_length(n - 1) < run_length(n + 1)
          elsif run_length(n) > run_length(n + 1)
            break
          end
          merge_at(n)
        end
      end

      def merge_force_collapse
        while @runs.size > 1
          n = @runs.size - 2
          n -= 1 if n.positive? && run_length(n - 1) < run_length(n + 1)
          merge_at(n)
        end
      end

      def run_length(index) = @runs[index][1]

      # Merges the runs at stack positions +index+ and +index + 1+.
      def merge_at(index)
        base1, length1 = @runs[index]
        base2, length2 = @runs[index + 1]
        @runs[index] = [base1, length1 + length2]
        @runs.delete_at(index + 1)

        # Elements of run 1 that are no larger than run 2's first element are already in place.
        skipped = gallop_right(@array[base2], @array, base1, length1, 0)
        base1 += skipped
        length1 -= skipped
        return if length1.zero?

        # Likewise, elements of run 2 that are no smaller than run 1's last element are already in place.
        length2 = gallop_left(@array[base1 + length1 - 1], @array, base2, length2, length2 - 1)
        return if length2.zero?

        merge_low(base1, length1, base2, length2)
      end

      # Merges two adjacent runs by copying the first into a temporary array and merging back from the front.
      def merge_low(base1, length1, base2, length2)
        temp = @array[base1, length1]
        cursor1 = 0 # into temp
        cursor2 = base2 # into @array
        dest = base1
        min_gallop = @min_gallop

        catch(:done) do
          @array[dest] = @array[cursor2]
          dest += 1
          cursor2 += 1
          length2 -= 1
          throw :done if length2.zero? || length1 == 1

          loop do
            count1 = 0 # consecutive wins by run 1
            count2 = 0 # consecutive wins by run 2

            # One element at a time, until one run wins MIN_GALLOP times in a row.
            loop do
              if less?(@array[cursor2], temp[cursor1])
                @array[dest] = @array[cursor2]
                dest += 1
                cursor2 += 1
                count2 += 1
                count1 = 0
                length2 -= 1
                throw :done if length2.zero?
              else
                @array[dest] = temp[cursor1]
                dest += 1
                cursor1 += 1
                count1 += 1
                count2 = 0
                length1 -= 1
                throw :done if length1 == 1
              end
              break if count1 >= min_gallop || count2 >= min_gallop
            end

            # Galloping: find how far each run's winning streak goes with an exponential search, and copy it in bulk.
            loop do
              count1 = gallop_right(@array[cursor2], temp, cursor1, length1, 0)
              count1.times do
                @array[dest] = temp[cursor1]
                dest += 1
                cursor1 += 1
              end
              length1 -= count1
              throw :done if length1 <= 1

              @array[dest] = @array[cursor2]
              dest += 1
              cursor2 += 1
              length2 -= 1
              throw :done if length2.zero?

              count2 = gallop_left(temp[cursor1], @array, cursor2, length2, 0)
              count2.times do
                @array[dest] = @array[cursor2]
                dest += 1
                cursor2 += 1
              end
              length2 -= count2
              throw :done if length2.zero?

              @array[dest] = temp[cursor1]
              dest += 1
              cursor1 += 1
              length1 -= 1
              throw :done if length1 == 1

              min_gallop -= 1
              break if count1 < MIN_GALLOP && count2 < MIN_GALLOP
            end
            # Leaving galloping mode makes it a little harder to re-enter.
            min_gallop = [min_gallop, 0].max + 2
          end
        end
        @min_gallop = [min_gallop, 1].max

        if length1 == 1
          # Run 1's last element is larger than everything left in run 2, which slides down to make room for it.
          length2.times do
            @array[dest] = @array[cursor2]
            dest += 1
            cursor2 += 1
          end
          @array[dest] = temp[cursor1]
        else
          # Run 2 is exhausted, so the rest of run 1 fills the gap. (Nothing is left at all only if the comparison is
          # inconsistent, in which case every element is still in the array.)
          length1.times do
            @array[dest] = temp[cursor1]
            dest += 1
            cursor1 += 1
          end
        end
      end

      # Returns the leftmost position in +array[base, length]+ where +key+ could be inserted keeping it sorted, i.e. the
      # number of elements less than +key+. The search starts at +base + hint+ and gallops outwards from there.
      def gallop_left(key, array, base, length, hint)
        last_offset = 0
        offset = 1
        if less?(array[base + hint], key)
          # Gallop right until array[base + hint + last_offset] < key <= array[base + hint + offset].
          max_offset = length - hint
          while offset < max_offset && less?(array[base + hint + offset], key)
            last_offset = offset
            offset = (offset * 2) + 1
          end
          offset = [offset, max_offset].min
          last_offset += hint
          offset += hint
        else
          # Gallop left until array[base + hint - offset] < key <= array[base + hint - last_offset].
          max_offset = hint + 1
          while offset < max_offset && !less?(array[base + hint - offset], key)
            last_offset = offset
            offset = (offset * 2) + 1
          end
          offset = [offset, max_offset].min
          last_offset, offset = hint - offset, hint - last_offset
        end

        # Binary search: array[base + last_offset] < key <= array[base + offset].
        last_offset += 1
        while last_offset < offset
          mid = last_offset + ((offset - last_offset) / 2)
          if less?(array[base + mid], key)
            last_offset = mid + 1
          else
            offset = mid
          end
        end
        offset
      end

      # Like #gallop_left, but returns the rightmost position, i.e. the number of elements less than or equal to
      # +key+. Placing a run-2 element after equal run-1 elements is what keeps merges stable.
      def gallop_right(key, array, base, length, hint)
        last_offset = 0
        offset = 1
        if less?(key, array[base + hint])
          # Gallop left until array[base + hint - offset] <= key < array[base + hint - last_offset].
          max_offset = hint + 1
          while offset < max_offset && less?(key, array[base + hint - offset])
            last_offset = offset
            offset = (offset * 2) + 1
          end
          offset = [offset, max_offset].min
          last_offset, offset = hint - offset, hint - last_offset
        else
          # Gallop right until array[base + hint + last_offset] <= key < array[base + hint + offset].
          max_offset = length - hint
          while offset < max_offset && !less?(key, array[base + hint + offset])
            last_offset = offset
            offset = (offset * 2) + 1
          end
          offset = [offset, max_offset].min
          last_offset += hint
          offset += hint
        end

        # Binary search: array[base + last_offset] <= key < array[base + offset].
        last_offset += 1
        while last_offset < offset
          mid = last_offset + ((offset - last_offset) / 2)
          if less?(key, array[base + mid])
            offset = mid
          else
            last_offset = mid + 1
          end
        end
        offset
      end
    end
  end

  register :tim, TimSort, title: 'Timsort', stable: true,
                          best: 'n', average: 'n log n', worst: 'n log n', space: 'n'
end
