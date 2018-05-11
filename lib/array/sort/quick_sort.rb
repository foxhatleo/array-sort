# frozen_string_literal: true

class Array
  def quick_sort(&block)
    return dup if length <= 1
    left, right = self[1..-1].partition { |y| sort_compare(first, y, &block).positive? }
    left.quick_sort + [first] + right.quick_sort
  end

  def quick_sort!(&block)
    become_clone_of quick_sort(&block)
  end

  def quick_sort_by(&_block)
    if block_given?
      quick_sort do |a, b|
        yield(a) <=> yield(b)
      end
    else
      to_enum :quick_sort_by
    end
  end

  def quick_sort_by!(&block)
    if block_given?
      become_clone_of quick_sort_by(&block)
    else
      to_enum :quick_sort_by!
    end
  end
end
