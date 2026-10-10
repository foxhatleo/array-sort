# frozen_string_literal: true

# Loads ArraySort and adds its sort methods to every Array. Use +require 'array_sort'+ instead to load it without
# changing Array.
require_relative '../array_sort'

Array.include(ArraySort::ArrayMethods)
