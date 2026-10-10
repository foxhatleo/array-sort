# frozen_string_literal: true

module ArraySort
  # Shell sort: insertion sort over elements a gap apart, for a shrinking sequence of gaps ending in 1.
  #
  # Uses Marcin Ciura's gap sequence (1, 4, 10, 23, 57, 132, 301, 701), extended by a factor of 2.25 for longer
  # arrays. Its exact complexity is an open problem; in practice it grows a little faster than n log n.
  #
  # @api private
  module ShellSort
    CIURA_GAPS = [1, 4, 10, 23, 57, 132, 301, 701].freeze

    module_function

    def call(array, compare)
      length = array.length
      gaps(length).each do |gap|
        (gap...length).each do |i|
          element = array[i]
          j = i
          while j >= gap && compare.call(array[j - gap], element).positive?
            array[j] = array[j - gap]
            j -= gap
          end
          array[j] = element unless j == i
        end
      end
      array
    end

    # Returns the gaps to use for an array of +length+ elements, largest first.
    def gaps(length)
      gaps = CIURA_GAPS.dup
      gaps << (gaps.last * 2.25).floor while gaps.last < length
      gaps.select { |gap| gap < length }.reverse
    end
  end

  register :shell, ShellSort, title: 'Shell sort', stable: false,
                              best: 'n log n', average: '≈ n^1.3', worst: 'unknown', space: '1'
end
