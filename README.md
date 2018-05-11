# ArraySort

ArraySort adds methods in the Ruby Array class that provides sorting methods using popular sorting algorithms.

Currently, the following sorting algorithms are implemented:
 * Bubble sort _(stable)_
 * Heap sort _(unstable)_
 * Insertion sort _(stable)_
 * Merge sort _(stable)_
 * Quicksort _(unstable)_

Note that this gem does not overwrite `Array#sort`, `Array#sort!`, `Array#sort_by`, or `Array#sort_by!`. Calling those
methods will invoke the native sorting methods, which use in-place quicksort algorithm and are unstable.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'array-sort'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install array-sort

## Usage

All sort methods share the same signature of `Array#sort`, `Array#sort!`, `Array#sort_by` and `Array#sort_by!`. Simply
change the names of the sorting methods to the following corresponding methods of a specific sorting algorithm:

 * Bubble sort: `bubble_sort`, `bubble_sort!`, `bubble_sort_by`, `bubble_sort_by!`
 * Heap sort: `heap_sort`, `heap_sort!`, `heap_sort_by`, `heap_sort_by!`
 * Insertion sort: `insertion_sort`, `insertion_sort!`, `insertion_sort_by`, `insertion_sort_by!`
 * Merge sort: `merge_sort`, `merge_sort!`, `merge_sort_by`, `merge_sort_by!`
 * Quicksort: `quick_sort`, `quick_sort!`, `quick_sort_by`, `quick_sort_by!`
 
See the official [Ruby documentation](https://ruby-doc.org/core-2.5.0/Array.html#method-i-sort) on how to use the native
sorting methods of Array.

For example, to sort an array using insertion sort:

```ruby
[3, 1, 2].insertion_sort # => [1, 2, 3]

# The following two lines both produce [[1, 4], [2, 6], [3, 3]]
[[3, 3], [1, 4], [2, 6]].insertion_sort { |a, b| a[0] <=> b[0] }
[[3, 3], [1, 4], [2, 6]].insertion_sort_by { |e| e[0] }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at
[https://github.com/foxhatleo/array-sort](https://github.com/foxhatleo/array-sort). This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
