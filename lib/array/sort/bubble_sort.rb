# frozen_string_literal: true

class Array
  def bubble_sort(&block)
    dup.bubble_sort!(&block)
  end

  def bubble_sort!(&block)
    return self if length <= 1
    n = length
    loop do
      new_n = bubble_sort_check(n, &block)
      n = new_n
      break if n.zero?
    end
    self
  end

  def bubble_sort_by(&block)
    if block_given?
      dup.bubble_sort_by!(&block)
    else
      to_enum :bubble_sort_by
    end
  end

  def bubble_sort_by!(&_block)
    if block_given?
      bubble_sort! do |a, b|
        yield(a) <=> yield(b)
      end
    else
      to_enum :bubble_sort_by!
    end
  end

  private

  def bubble_sort_check(length_checking, &block)
    new_n = 0
    (1...length_checking).each do |i|
      next unless sort_compare(self[i - 1], self[i], &block).positive?
      swap i - 1, i
      new_n = i
    end
    new_n
  end
end
