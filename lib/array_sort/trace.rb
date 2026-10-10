# frozen_string_literal: true

module ArraySort
  # A record of everything a sorting algorithm did: every comparison it made and every write to the array, in order.
  # Build one with {ArraySort.trace}.
  #
  # Replaying the writes onto a copy of {#input} reproduces {#result} step by step, which makes traces handy for
  # visualizing or teaching how the algorithms differ.
  class Trace
    # One comparison between two elements. +result+ is -1, 0 or 1.
    Comparison = Data.define(:left, :right, :result)

    # One assignment +array[index] = value+. A swap shows up as two writes.
    Write = Data.define(:index, :value)

    # @return [Algorithm] the algorithm that ran
    attr_reader :algorithm
    # @return [Array] a copy of the array before sorting
    attr_reader :input
    # @return [Array] the sorted array
    attr_reader :result
    # @return [Array<Comparison, Write>] everything the algorithm did, in order
    attr_reader :events

    # @api private
    def initialize(algorithm, input, result, events)
      @algorithm = algorithm
      @input = input
      @result = result
      @events = events
    end

    # @return [Integer] how many comparisons were made
    def comparisons
      events.count { |event| event.is_a?(Comparison) }
    end

    # @return [Integer] how many elements were written
    def writes
      events.count { |event| event.is_a?(Write) }
    end

    # The array handed to the algorithm while tracing. It reports every element assignment.
    #
    # @api private
    class Buffer < Array
      def initialize(array, on_write)
        super(array, &nil)
        @on_write = on_write
      end

      # Only single-element assignment is supported; algorithms must not use the range or length forms.
      def []=(index, value)
        @on_write.call(index, value)
        super
      end
    end
    private_constant :Buffer

    # @api private
    def self.run(name, array, &on_event)
      algorithm = ArraySort.algorithm(name)
      input = Array.new(array).freeze
      events = []
      record = lambda do |event|
        events << event
        on_event&.call(event)
      end

      buffer = Buffer.new(input, ->(index, value) { record.call(Write.new(index:, value:)) })
      algorithm.implementation.call(buffer, algorithm.comparison? ? recording_comparator(record) : lambda { |element|
        element
      })
      new(algorithm, input, Array.new(buffer), events.freeze)
    end

    # Compares with <=> like an untraced sort, and records each comparison.
    def self.recording_comparator(record)
      compare = Core.comparator(nil)
      lambda do |a, b|
        compare.call(a, b).tap { |result| record.call(Comparison.new(left: a, right: b, result: result <=> 0)) }
      end
    end
    private_class_method :recording_comparator
  end

  class << self
    # Sorts a copy of +array+ with the named algorithm, recording each comparison and write.
    #
    # Elements are compared with +<=>+ (distribution sorts never compare; they need Integer elements, or real numbers
    # for bucket sort).
    #
    # @example
    #   trace = ArraySort.trace(:insertion, [3, 1, 2])
    #   trace.result      # => [1, 2, 3]
    #   trace.comparisons # => 3
    #   trace.events.first
    #   # => #<data ArraySort::Trace::Comparison left=3, right=1, result=1>
    #
    # @example Streaming events as they happen
    #   ArraySort.trace(:heap, [3, 1, 2]) { |event| puts event.inspect }
    #
    # @param name [Symbol, String] one of {ArraySort.algorithms}
    # @param array [Array] the array to sort; it is not modified
    # @yieldparam event [Trace::Comparison, Trace::Write] each event, as it happens
    # @return [Trace]
    def trace(name, array, &)
      Trace.run(name, array, &)
    end
  end
end
