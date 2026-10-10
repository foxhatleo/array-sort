# frozen_string_literal: true

module ArraySort
  # Heap sort: builds a max-heap in place, then repeatedly swaps the largest element to the end of the unsorted region
  # and restores the heap over what remains.
  #
  # @api private
  module HeapSort
    module_function

    def call(array, compare)
      sort_range(array, compare, 0, array.length - 1)
      array
    end

    # Sorts +array[low..high]+. Heap positions are counted from +low+, so the heap's root is +array[low]+.
    def sort_range(array, compare, low, high)
      last = high - low
      ((last - 1) / 2).downto(0) { |root| sift_down(array, compare, low, root, last) }
      last.downto(1) do |boundary|
        array[low], array[low + boundary] = array[low + boundary], array[low]
        sift_down(array, compare, low, 0, boundary - 1)
      end
    end

    # Moves the element at heap position +root+ down until neither child (up to position +last+) is larger than it.
    def sift_down(array, compare, base, root, last)
      loop do
        child = (root * 2) + 1
        break if child > last

        child += 1 if child < last && compare.call(array[base + child], array[base + child + 1]).negative?
        break unless compare.call(array[base + root], array[base + child]).negative?

        array[base + root], array[base + child] = array[base + child], array[base + root]
        root = child
      end
    end
  end

  register :heap, HeapSort, title: 'Heap sort', stable: false,
                            best: 'n log n', average: 'n log n', worst: 'n log n', space: '1'
end
