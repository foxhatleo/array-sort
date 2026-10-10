# frozen_string_literal: true

module ArraySort
  # Shared plumbing behind every public sort method on +Array+.
  #
  # Each algorithm is a module that responds to +call(buffer, compare)+ and sorts +buffer+ in place, where +compare+
  # is a lambda returning a negative, zero or positive Integer. Everything else (copying, frozen checks, key caching
  # for the +_by+ variants, enumerators) lives here so the algorithms stay focused on the algorithm.
  #
  # @api private
  module Core
    module_function

    # Returns a new, sorted copy of +array+.
    def sort(array, algorithm, &block)
      buffer = Array.new(array)
      algorithm.call(buffer, comparator(block))
      buffer
    end

    # Sorts +array+ in place and returns it.
    #
    # The work happens on a private copy that replaces the contents of +array+ only once sorting has finished, so if
    # the comparison raises, +array+ is left exactly as it was (matching +Array#sort!+).
    def sort!(array, algorithm, &)
      ensure_mutable!(array)
      array.replace(sort(array, algorithm, &))
    end

    # Returns a new copy of +array+ sorted by the keys the block produces.
    #
    # Like +Array#sort_by+, the block is called exactly once per element.
    def sort_by(array, algorithm, &block)
      keyed = array.map { |element| [block.call(element), element] }
      algorithm.call(keyed, ->(a, b) { normalize(a[0] <=> b[0], a[0], b[0]) })
      keyed.map!(&:last)
    end

    # Sorts +array+ in place by the keys the block produces and returns it.
    def sort_by!(array, algorithm, &)
      ensure_mutable!(array)
      array.replace(sort_by(array, algorithm, &))
    end

    # Wraps a comparison (the user's block, or +<=>+) so that it always returns an Integer, raising the same
    # +ArgumentError+ as +Array#sort+ when two elements cannot be compared.
    def comparator(block)
      if block
        ->(a, b) { normalize(block.call(a, b), a, b) }
      else
        ->(a, b) { normalize(a <=> b, a, b) }
      end
    end

    def normalize(result, element1, element2)
      return result if result.is_a?(Integer)

      sign = result <=> 0 unless result.nil?
      raise ArgumentError, "comparison of #{element1.class} with #{element2.class} failed" if sign.nil?

      sign
    end

    def ensure_mutable!(array)
      raise FrozenError.new("can't modify frozen #{array.class}: #{array.inspect}", receiver: array) if array.frozen?
    end
  end
end
