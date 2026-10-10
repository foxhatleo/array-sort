# frozen_string_literal: true

module ArraySort
  # Adds the {ArrayMethods} to Array only in files that opt in, instead of everywhere.
  #
  # @example
  #   require 'array_sort'
  #   using ArraySort::Refinements
  #
  #   [3, 1, 2].merge_sort # => [1, 2, 3]
  module Refinements
    refine Array do
      import_methods ArraySort::ArrayMethods
    end
  end
end
