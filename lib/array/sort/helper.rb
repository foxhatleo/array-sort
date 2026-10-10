# frozen_string_literal: true

class Array
  # Swap two elements in the array, and returns +self+.
  #
  # Negative indices count from the end of the array, as with +Array#[]+.
  #
  # @param index1 [Integer] The index of the first element.
  # @param index2 [Integer] The index of the second element.
  # @return [Array] +self+
  # @raise [ArgumentError] If either of the two parameters is not an Integer.
  # @raise [IndexError] If either index is outside the bounds of the array.
  def swap(index1, index2)
    raise ArgumentError, 'Index must be an integer.' unless index1.is_a?(Integer) && index2.is_a?(Integer)

    fetch(index1)
    fetch(index2)
    self[index1], self[index2] = self[index2], self[index1] if index1 != index2
    self
  end
end
