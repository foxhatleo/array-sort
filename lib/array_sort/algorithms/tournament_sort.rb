# frozen_string_literal: true

module ArraySort
  # Tournament sort: runs a knockout tournament between the elements, where each match is won by the smaller one. The
  # champion is the smallest element; it is removed and only the matches it played are replayed to find the next.
  #
  # Each replay takes log n comparisons. Ties are won by the element that came first, which makes the sort stable.
  #
  # @api private
  module TournamentSort
    module_function

    def call(array, compare)
      count = array.length
      return array if count < 2

      elements = Array.new(array)
      leaves = 1
      leaves <<= 1 while leaves < count

      # A complete binary tree stored in an array: node i has children 2i and 2i + 1, leaves are leaves...2 * leaves,
      # and every node holds the index of the element that won there (nil once that element has been taken).
      tree = Array.new(2 * leaves)
      count.times { |i| tree[leaves + i] = i }
      (leaves - 1).downto(1) { |node| tree[node] = winner(elements, compare, tree[2 * node], tree[(2 * node) + 1]) }

      count.times do |position|
        champion = tree[1]
        array[position] = elements[champion]

        node = leaves + champion
        tree[node] = nil
        while node > 1
          node /= 2
          tree[node] = winner(elements, compare, tree[2 * node], tree[(2 * node) + 1])
        end
      end
      array
    end

    # Returns whichever of the element indices +left+ and +right+ wins (is smaller). +left+ always comes from earlier
    # in the array, so it wins ties.
    def winner(elements, compare, left, right)
      return right if left.nil?
      return left if right.nil?

      compare.call(elements[right], elements[left]).negative? ? right : left
    end
  end

  register :tournament, TournamentSort, title: 'Tournament sort', stable: true,
                                        best: 'n log n', average: 'n log n', worst: 'n log n', space: 'n'
end
