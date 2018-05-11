# frozen_string_literal: true

class Array
  # Swap two elements in the array, and returns +self+.
  #
  # @param index1 [Integer] The index of the first element.
  # @param index2 [Integer] The index of the second element.
  # @return [Array]
  # @raise [ArgumentError] If either of the two parameters is not an Integer.
  def swap(index1, index2)
    raise ArgumentError, 'Index must be an integer.' unless index1.is_a?(Integer) && index2.is_a?(Integer)
    self[index1], self[index2] = self[index2], self[index1] if index1 != index2
    self
  end

  private

  # Compare two elements.
  #
  # If a block is provided, it will be used to compare the two elements. If not, operator +<=>+ will be used.
  def sort_compare(element1, element2, &_block)
    if block_given?
      yield element1, element2
    else
      element1 <=> element2
    end
  end

  # Clear everything in +self+, and add all elements in +target+.
  def become_clone_of(target)
    clear
    concat target
  end
end
