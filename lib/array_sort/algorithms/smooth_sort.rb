# frozen_string_literal: true

module ArraySort
  # Smoothsort: Edsger Dijkstra's heap sort variant that runs in O(n) on already-sorted input while keeping heap sort's
  # O(n log n) worst case and O(1) extra space.
  #
  # Instead of one binary heap, it keeps a row of max-heaps whose sizes are Leonardo numbers (1, 1, 3, 5, 9, 15, ...,
  # each the sum of the previous two plus one), with their roots in ascending order from left to right. The largest
  # element is therefore always the rightmost root. Growing the row one element at a time builds it; shrinking it one
  # element at a time, while repairing the row, leaves the array sorted.
  #
  # @api private
  module SmoothSort
    module_function

    def call(array, compare)
      length = array.length
      return array if length < 2

      sizes = leonardo_numbers(length)
      orders = [] # the order (index into sizes) of each heap in the row, left to right

      # Build: add each element as the root of a new heap, merging the last two heaps when their orders are
      # consecutive, then move it to its place among the roots.
      length.times do |root|
        if orders.length >= 2 && orders[-2] == orders[-1] + 1
          orders.pop
          orders[-1] += 1
        elsif orders.last == 1
          orders.push(0)
        else
          orders.push(1)
        end
        restore_roots(array, compare, sizes, orders, orders.length - 1, root)
      end

      # Take apart: the last element is the largest, so it is in place. Removing it splits its heap into its two
      # subheaps, whose roots then need to find their place in the row.
      (length - 1).downto(1) do |root|
        order = orders.pop
        next if order < 2

        left_root = root - 1 - sizes[order - 2]
        orders.push(order - 1)
        restore_roots(array, compare, sizes, orders, orders.length - 1, left_root)
        orders.push(order - 2)
        restore_roots(array, compare, sizes, orders, orders.length - 1, root - 1)
      end
      array
    end

    # Returns the Leonardo numbers up to the first one that is at least +length+.
    def leonardo_numbers(length)
      numbers = [1, 1]
      numbers << (numbers[-1] + numbers[-2] + 1) while numbers.last < length
      numbers
    end

    # Moves the value at +root+ (the root of heap +heap+ in the row) leftwards past larger roots, then sifts it down
    # into whichever heap it ends up in.
    def restore_roots(array, compare, sizes, orders, heap, root)
      while heap.positive?
        previous_root = root - sizes[orders[heap]]
        break unless compare.call(array[previous_root], array[root]).positive?

        # The previous root may only move into this heap if it is also larger than this root's children.
        order = orders[heap]
        if order >= 2
          right_child = root - 1
          left_child = right_child - sizes[order - 2]
          break unless compare.call(array[previous_root], array[left_child]).positive? &&
                       compare.call(array[previous_root], array[right_child]).positive?
        end

        array[previous_root], array[root] = array[root], array[previous_root]
        root = previous_root
        heap -= 1
      end
      sift_down(array, compare, sizes, root, orders[heap])
    end

    # Restores the max-heap property of the Leonardo heap of the given +order+ rooted at +root+. Its left subheap has
    # order - 1 and its right subheap order - 2, with the right subheap's root just before +root+.
    def sift_down(array, compare, sizes, root, order)
      while order >= 2
        right_child = root - 1
        left_child = right_child - sizes[order - 2]
        if compare.call(array[left_child], array[right_child]).negative?
          child = right_child
          child_order = order - 2
        else
          child = left_child
          child_order = order - 1
        end
        break unless compare.call(array[root], array[child]).negative?

        array[root], array[child] = array[child], array[root]
        root = child
        order = child_order
      end
    end
  end

  register :smooth, SmoothSort, title: 'Smoothsort', stable: false,
                                best: 'n', average: 'n log n', worst: 'n log n', space: '1'
end
