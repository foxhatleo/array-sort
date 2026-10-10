# frozen_string_literal: true

module ArraySort
  # For every algorithm name +x+ in {ArraySort.algorithms}, ArraySort responds to +x_sort(array, &block)+,
  # +x_sort!(array, &block)+, +x_sort_by(array, &block)+ and +x_sort_by!(array, &block)+. They behave exactly like
  # the Array methods of the same name (see {ArrayMethods}) but take the array as an argument, so they work without
  # patching Array.
  #
  # @example
  #   require 'array_sort'
  #   ArraySort.merge_sort([3, 1, 2])            # => [1, 2, 3]
  #   ArraySort.quick_sort_by(%w[ccc a bb], &:size) # => ["a", "bb", "ccc"]
  ArraySort.algorithms.each do |name|
    define_singleton_method(:"#{name}_sort") { |array, &block| Core.sort(array, name, &block) }
    define_singleton_method(:"#{name}_sort!") { |array, &block| Core.sort!(array, name, &block) }
    define_singleton_method(:"#{name}_sort_by") do |array, &block|
      block ? Core.sort_by(array, name, &block) : Core.sort_by_enumerator(array, name, bang: false)
    end
    define_singleton_method(:"#{name}_sort_by!") do |array, &block|
      block ? Core.sort_by!(array, name, &block) : Core.sort_by_enumerator(array, name, bang: true)
    end
  end
end
