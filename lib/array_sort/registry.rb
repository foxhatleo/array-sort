# frozen_string_literal: true

module ArraySort
  # Describes one sorting algorithm: what it is called, whether it is stable, and its complexity.
  #
  # Complexities are written without the O(...), e.g. +"n log n"+. In the distribution sorts, +k+ is the range of the
  # keys (largest minus smallest) and +w+ is the number of bytes in the largest key.
  #
  # @!attribute [r] name
  #   @return [Symbol] the method prefix, e.g. +:merge+ for +merge_sort+
  # @!attribute [r] title
  #   @return [String] the human-readable name, e.g. +"Merge sort"+
  # @!attribute [r] kind
  #   @return [Symbol] +:comparison+ for sorts that compare elements (and accept a comparison block), or
  #     +:distribution+ for sorts that place elements by numeric key (Integer, or any real number for bucket sort)
  # @!attribute [r] best
  #   @return [String] best-case time complexity
  # @!attribute [r] average
  #   @return [String] average-case time complexity
  # @!attribute [r] worst
  #   @return [String] worst-case time complexity
  # @!attribute [r] space
  #   @return [String] extra space used, beyond the copy made by the non-bang methods
  Algorithm = Data.define(:name, :title, :implementation, :stable, :kind, :best, :average, :worst, :space) do
    # @return [Boolean] whether elements that compare equal keep their original relative order
    def stable? = stable

    # @return [Boolean] whether the algorithm sorts by comparing elements
    def comparison? = kind == :comparison

    # @return [Boolean] whether the algorithm sorts by distributing numeric keys, without comparing elements
    def distribution? = kind == :distribution
  end

  @algorithms = {}

  class << self
    # Returns the names of every available algorithm, in alphabetical order. Each name +x+ provides +x_sort+,
    # +x_sort!+, +x_sort_by+ and +x_sort_by!+.
    #
    # @example
    #   ArraySort.algorithms # => [:binary_insertion, :bubble, :bucket, ...]
    # @return [Array<Symbol>]
    def algorithms
      @algorithms.keys.sort
    end

    # Returns the description of an algorithm.
    #
    # @example
    #   ArraySort.algorithm(:merge).stable? # => true
    # @param name [Symbol, String]
    # @return [Algorithm]
    # @raise [ArgumentError] if there is no algorithm with that name
    def algorithm(name)
      @algorithms.fetch(name.to_sym) { raise ArgumentError, "unknown sorting algorithm: #{name.inspect}" }
    end

    private

    # Called by each algorithm file to add itself.
    def register(name, implementation, title:, stable:, best:, average:, worst:, space:, kind: :comparison)
      raise "algorithm #{name.inspect} is already registered" if @algorithms.key?(name)

      @algorithms[name] = Algorithm.new(name:, title:, implementation:, stable:, kind:, best:, average:, worst:, space:)
    end
  end
end
