# frozen_string_literal: true

# Popular sorting algorithms for Ruby arrays.
#
# Requiring +array_sort+ loads everything without changing Array. From there, sort with the module functions
# (+ArraySort.merge_sort(array)+), or opt in per file with +using ArraySort::Refinements+. Requiring +array/sort+
# instead also adds the sort methods to every Array.
module ArraySort
end

require_relative 'array_sort/version'
require_relative 'array_sort/registry'
require_relative 'array_sort/core'

# Algorithms some others build on come first.
require_relative 'array_sort/algorithms/bubble_sort'
require_relative 'array_sort/algorithms/heap_sort'
require_relative 'array_sort/algorithms/insertion_sort'
require_relative 'array_sort/algorithms/quick_sort'

require_relative 'array_sort/algorithms/binary_insertion_sort'
require_relative 'array_sort/algorithms/bucket_sort'
require_relative 'array_sort/algorithms/cocktail_shaker_sort'
require_relative 'array_sort/algorithms/comb_sort'
require_relative 'array_sort/algorithms/counting_sort'
require_relative 'array_sort/algorithms/cycle_sort'
require_relative 'array_sort/algorithms/gnome_sort'
require_relative 'array_sort/algorithms/intro_sort'
require_relative 'array_sort/algorithms/merge_sort'
require_relative 'array_sort/algorithms/odd_even_sort'
require_relative 'array_sort/algorithms/pancake_sort'
require_relative 'array_sort/algorithms/radix_sort'
require_relative 'array_sort/algorithms/selection_sort'
require_relative 'array_sort/algorithms/shell_sort'
require_relative 'array_sort/algorithms/smooth_sort'
require_relative 'array_sort/algorithms/tim_sort'
require_relative 'array_sort/algorithms/tournament_sort'
require_relative 'array_sort/algorithms/tree_sort'

require_relative 'array_sort/array_methods'
require_relative 'array_sort/functions'
require_relative 'array_sort/refinements'
require_relative 'array_sort/trace'
