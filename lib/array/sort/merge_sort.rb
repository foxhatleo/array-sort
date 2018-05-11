# frozen_string_literal: true

class Array
  def merge_sort(&block)
    return dup if length <= 1
    divided_parts = merge_sort_divide
    part_a_sorted = divided_parts[0].merge_sort
    part_b_sorted = divided_parts[1].merge_sort
    merge_sort_merge part_a_sorted, part_b_sorted, &block
  end

  def merge_sort!(&block)
    become_clone_of merge_sort(&block)
  end

  def merge_sort_by(&_block)
    if block_given?
      merge_sort do |a, b|
        yield(a) <=> yield(b)
      end
    else
      to_enum :merge_sort_by
    end
  end

  def merge_sort_by!(&block)
    if block_given?
      become_clone_of merge_sort_by(&block)
    else
      to_enum :merge_sort_by!
    end
  end

  private

  def merge_sort_divide
    mid = length / 2
    part_a = self[0, mid]
    part_b = self[mid..-1]
    [part_a, part_b]
  end

  def merge_sort_merge(part_a, part_b, &block)
    result = []
    while part_a.length.positive? && part_b.length.positive?
      result << (sort_compare(part_a.first, part_b.first, &block).positive? ? part_b : part_a).shift
    end
    result + part_a + part_b
  end
end
