# frozen_string_literal: true

module ArraySort
  # Gnome sort: a garden gnome walks along a line of flower pots, swapping each pot backwards while it is smaller than
  # the one before it, then returning to where it left off.
  #
  # This is the common variant where the gnome remembers its position instead of walking back step by step, which
  # also guarantees it finishes even if the comparison is inconsistent.
  #
  # @api private
  module GnomeSort
    module_function

    def call(array, compare)
      (1...array.length).each do |position|
        i = position
        while i.positive? && compare.call(array[i - 1], array[i]).positive?
          array[i - 1], array[i] = array[i], array[i - 1]
          i -= 1
        end
      end
      array
    end
  end

  register :gnome, GnomeSort, title: 'Gnome sort', stable: true,
                              best: 'n', average: 'n²', worst: 'n²', space: '1'
end
