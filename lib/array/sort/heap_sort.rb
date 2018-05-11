# frozen_string_literal: true

class Array
  def heap_sort(&block)
    dup.heap_sort!(&block)
  end

  def heap_sort!(&block)
    return self if length <= 1
    heapify(&block)
    (length - 1).downto(1) do |end_|
      swap(end_, 0)
      sift_down(0, end_ - 1, &block)
    end
    self
  end

  def heap_sort_by(&block)
    if block_given?
      dup.heap_sort_by!(&block)
    else
      to_enum :heap_sort_by
    end
  end

  def heap_sort_by!(&_block)
    if block_given?
      heap_sort! do |a, b|
        yield(a) <=> yield(b)
      end
    else
      to_enum :heap_sort_by!
    end
  end

  private

  def heapify(&block)
    end_ = length - 1
    (length / 2 - 1).downto(0) do |start|
      sift_down(start, end_, &block)
    end
  end

  def sift_down(start, end_, &block)
    root = start
    loop do
      child = root * 2 + 1
      break if child > end_
      child += 1 if check_less_than_sibling(child, end_, &block)
      break if check_max_heap_order(root, child, &block)
      root = child
    end
  end

  def check_less_than_sibling(child, end_, &block)
    child + 1 <= end_ && sort_compare(self[child], self[child + 1], &block) == -1
  end

  def check_max_heap_order(root, child, &block)
    return true unless sort_compare(self[root], self[child], &block) == -1
    swap root, child
    false
  end
end
