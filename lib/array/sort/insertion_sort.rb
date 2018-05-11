# frozen_string_literal: true

class Array
  def insertion_sort(&block)
    dup.insertion_sort!(&block)
  end

  def insertion_sort!(&block)
    return self if length <= 1
    (1...length).each do |i|
      i.downto(1) do |j|
        break unless sort_compare(self[j - 1], self[j], &block) == 1
        swap(j - 1, j)
      end
    end
    self
  end

  def insertion_sort_by(&block)
    if block_given?
      dup.insertion_sort_by!(&block)
    else
      to_enum :insertion_sort_by
    end
  end

  def insertion_sort_by!(&_block)
    if block_given?
      insertion_sort! do |a, b|
        yield(a) <=> yield(b)
      end
    else
      to_enum :insertion_sort_by!
    end
  end
end
