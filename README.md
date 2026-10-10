# ArraySort

[![Gem Version](https://badge.fury.io/rb/array-sort.svg)](https://badge.fury.io/rb/array-sort)
[![CI](https://github.com/foxhatleo/array-sort/actions/workflows/ci.yml/badge.svg)](https://github.com/foxhatleo/array-sort/actions/workflows/ci.yml)

ArraySort adds methods to Ruby's `Array` class for sorting with popular sorting algorithms.

| Algorithm      | Time (best / average / worst)   | Extra space | Stable |
| -------------- | ------------------------------- | ----------- | ------ |
| Bubble sort    | O(n) / O(n²) / O(n²)            | O(1)        | Yes    |
| Heap sort      | O(n log n) in all cases         | O(1)        | No     |
| Insertion sort | O(n) / O(n²) / O(n²)            | O(1)        | Yes    |
| Merge sort     | O(n) / O(n log n) / O(n log n)  | O(n)        | Yes    |
| Quicksort      | O(n log n) / O(n log n) / O(n²) | O(log n)    | No     |

Quicksort picks a random pivot, so its O(n²) worst case is vanishingly unlikely on any input, including sorted or
reverse-sorted arrays.

This gem does not override `Array#sort`, `Array#sort!`, `Array#sort_by` or `Array#sort_by!`. Those keep using Ruby's
native implementation, which is much faster than anything written in Ruby but is not stable. Reach for this gem when
you need a stable sort, want to learn how these algorithms behave, or want to compare them.

## Installation

Requires Ruby 3.2 or later. Add this line to your application's Gemfile:

```ruby
gem 'array-sort'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install array-sort

If you're not using Bundler, `require 'array/sort'`.

## Usage

Every algorithm comes with the same four methods as `Array#sort`, `Array#sort!`, `Array#sort_by` and `Array#sort_by!`,
with the same signatures:

 * Bubble sort: `bubble_sort`, `bubble_sort!`, `bubble_sort_by`, `bubble_sort_by!`
 * Heap sort: `heap_sort`, `heap_sort!`, `heap_sort_by`, `heap_sort_by!`
 * Insertion sort: `insertion_sort`, `insertion_sort!`, `insertion_sort_by`, `insertion_sort_by!`
 * Merge sort: `merge_sort`, `merge_sort!`, `merge_sort_by`, `merge_sort_by!`
 * Quicksort: `quick_sort`, `quick_sort!`, `quick_sort_by`, `quick_sort_by!`

For example, to sort an array using insertion sort:

```ruby
[3, 1, 2].insertion_sort # => [1, 2, 3]

# Sort with a comparison block, here in descending order
[3, 1, 2].merge_sort { |a, b| b <=> a } # => [3, 2, 1]

# The following two lines both produce [[1, 4], [2, 6], [3, 3]]
[[3, 3], [1, 4], [2, 6]].insertion_sort { |a, b| a[0] <=> b[0] }
[[3, 3], [1, 4], [2, 6]].insertion_sort_by { |e| e[0] }

# Stable algorithms keep equal elements in their original order
%w[pear fig apple kiwi].merge_sort_by(&:length) # => ["fig", "pear", "kiwi", "apple"]
```

The methods behave like their native counterparts (see the
[Ruby documentation](https://docs.ruby-lang.org/en/master/Array.html#method-i-sort)):

 * Without a bang, a new `Array` is returned and the receiver is left alone.
 * With a bang, the receiver is sorted in place and returned. If the comparison raises partway through, the receiver
   is left unchanged. Calling a bang method on a frozen array raises `FrozenError`.
 * A comparison block may return any number; only its sign matters. If two elements can't be compared (`<=>` or the
   block returns `nil`), an `ArgumentError` is raised.
 * The `_by` methods call their block exactly once per element, and return an `Enumerator` when called without one.

The gem also adds `Array#swap`, which swaps two elements in place:

```ruby
[1, 2, 3].swap(0, -1) # => [3, 2, 1]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run `bundle exec rake` to run the tests and
RuboCop (or `bundle exec rake test` for just the tests). You can also run `bin/console` for an interactive prompt that
will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at
[https://github.com/foxhatleo/array-sort](https://github.com/foxhatleo/array-sort). This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to adhere to the
[Contributor Covenant](https://www.contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
