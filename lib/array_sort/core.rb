# frozen_string_literal: true

module ArraySort
  # Shared plumbing behind every public sort method.
  #
  # Algorithms come in two kinds (see {Algorithm#kind}):
  #
  # * Comparison algorithms respond to +call(buffer, compare)+ and sort +buffer+ in place, where +compare+ is a lambda
  #   returning a negative, zero or positive Integer.
  # * Distribution algorithms respond to +call(buffer, key)+ and sort +buffer+ in place by the numeric key that the
  #   lambda +key+ returns for each element.
  #
  # Algorithms only ever change +buffer+ through single-element assignment (+buffer[i] = value+), which is what lets
  # {ArraySort.trace} record every write. Everything else (copying, frozen checks, key caching for the +_by+ variants,
  # enumerators) lives here so the algorithms stay focused on the algorithm.
  #
  # @api private
  module Core
    module_function

    IDENTITY = ->(element) { element }
    FIRST = ->(pair) { pair[0] }
    private_constant :IDENTITY, :FIRST

    # Returns a new, sorted copy of +array+.
    def sort(array, name, &block)
      algorithm = ArraySort.algorithm(name)
      buffer = Array.new(array)
      if algorithm.comparison?
        algorithm.implementation.call(buffer, comparator(block))
      else
        if block
          raise ArgumentError,
                "#{name}_sort sorts by numeric key and does not take a comparison block; use #{name}_sort_by instead"
        end

        algorithm.implementation.call(buffer, IDENTITY)
      end
      buffer
    end

    # Sorts +array+ in place and returns it.
    #
    # The work happens on a private copy that replaces the contents of +array+ only once sorting has finished, so if
    # the comparison raises, +array+ is left exactly as it was (matching +Array#sort!+).
    def sort!(array, name, &)
      ensure_mutable!(array)
      array.replace(sort(array, name, &))
    end

    # Returns a new copy of +array+ sorted by the keys the block produces.
    #
    # Like +Array#sort_by+, the block is called exactly once per element.
    def sort_by(array, name, &block)
      algorithm = ArraySort.algorithm(name)
      keyed = array.map { |element| [block.call(element), element] }
      by_key = algorithm.comparison? ? ->(a, b) { normalize(a[0] <=> b[0], a[0], b[0]) } : FIRST
      algorithm.implementation.call(keyed, by_key)
      keyed.map!(&:last)
    end

    # Sorts +array+ in place by the keys the block produces and returns it.
    def sort_by!(array, name, &)
      ensure_mutable!(array)
      array.replace(sort_by(array, name, &))
    end

    # Returns the Enumerator that +_sort_by+ and +_sort_by!+ return when called without a block.
    #
    # This is built by hand rather than with +to_enum+ so that it also works under {ArraySort::Refinements}: an
    # Enumerator made by +to_enum+ calls the method from outside the refined scope, where it doesn't exist.
    def sort_by_enumerator(array, name, bang:)
      method = bang ? :sort_by! : :sort_by
      Enumerator.new(-> { array.size }) do |yielder|
        public_send(method, array, name) { |element| yielder.yield(element) }
      end
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

    # Returns the keys of +array+ under +key+, checking that each one is an Integer.
    def integer_keys(array, key, algorithm_title)
      array.map do |element|
        value = key.call(element)
        raise ArgumentError, "#{algorithm_title} needs Integer keys, got #{value.class}" unless value.is_a?(Integer)

        value
      end
    end

    # Returns the keys of +array+ under +key+, checking that each one is a finite real number.
    def real_keys(array, key, algorithm_title)
      array.map do |element|
        value = key.call(element)
        unless value.is_a?(Numeric) && value.real? && value.finite?
          raise ArgumentError, "#{algorithm_title} needs finite real number keys, got #{value.inspect}"
        end

        value
      end
    end

    def ensure_mutable!(array)
      raise FrozenError.new("can't modify frozen #{array.class}: #{array.inspect}", receiver: array) if array.frozen?
    end
  end
end
