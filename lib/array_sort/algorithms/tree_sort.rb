# frozen_string_literal: true

module ArraySort
  # Tree sort: inserts every element into a binary search tree, then reads them back in order.
  #
  # The tree is an AVL tree, which rebalances itself on every insertion so that sorted input doesn't degrade it into a
  # linked list (the classic O(n²) trap of tree sort). Equal elements are inserted to the right of each other, so an
  # in-order walk returns them in their original order and the sort is stable.
  #
  # @api private
  module TreeSort
    Node = Struct.new(:value, :left, :right, :height)
    private_constant :Node

    module_function

    def call(array, compare)
      root = nil
      array.each { |element| root = insert(root, element, compare) }

      index = 0
      each_in_order(root) do |value|
        array[index] = value
        index += 1
      end
      array
    end

    def insert(node, value, compare)
      return Node.new(value, nil, nil, 1) if node.nil?

      if compare.call(value, node.value).negative?
        node.left = insert(node.left, value, compare)
      else
        node.right = insert(node.right, value, compare)
      end
      rebalance(node)
    end

    # Walks the tree in order without recursion.
    def each_in_order(node)
      stack = []
      while node || !stack.empty?
        while node
          stack.push(node)
          node = node.left
        end
        node = stack.pop
        yield node.value
        node = node.right
      end
    end

    def height(node) = node ? node.height : 0

    def balance(node) = height(node.left) - height(node.right)

    def update_height(node)
      node.height = [height(node.left), height(node.right)].max + 1
      node
    end

    # Restores the AVL property (subtree heights differ by at most one) at +node+ and returns the subtree's new root.
    # Rotations never change the in-order sequence, so they preserve both sorting and stability.
    def rebalance(node)
      update_height(node)
      case balance(node)
      when 2
        node.left = rotate_left(node.left) if balance(node.left).negative?
        rotate_right(node)
      when -2
        node.right = rotate_right(node.right) if balance(node.right).positive?
        rotate_left(node)
      else
        node
      end
    end

    def rotate_right(node)
      pivot = node.left
      node.left = pivot.right
      pivot.right = update_height(node)
      update_height(pivot)
    end

    def rotate_left(node)
      pivot = node.right
      node.right = pivot.left
      pivot.left = update_height(node)
      update_height(pivot)
    end
  end

  register :tree, TreeSort, title: 'Tree sort (AVL)', stable: true,
                            best: 'n log n', average: 'n log n', worst: 'n log n', space: 'n'
end
