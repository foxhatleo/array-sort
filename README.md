# ArraySort

[![Gem Version](https://badge.fury.io/rb/array-sort.svg)](https://badge.fury.io/rb/array-sort)
[![CI](https://github.com/foxhatleo/array-sort/actions/workflows/ci.yml/badge.svg)](https://github.com/foxhatleo/array-sort/actions/workflows/ci.yml)

ArraySort implements 22 sorting algorithms for Ruby arrays, from bubble sort to Timsort, all with the same interface
as `Array#sort`, `#sort!`, `#sort_by` and `#sort_by!`. Use them as `Array` methods, through a refinement, or as plain
module functions, and trace any of them to watch every comparison and write it makes.

```ruby
[3, 1, 2].tim_sort                                  # => [1, 2, 3]
[3, 1, 2].merge_sort { |a, b| b <=> a }             # => [3, 2, 1]
%w[pear fig apple kiwi].merge_sort_by(&:length)     # => ["fig", "pear", "kiwi", "apple"]
ArraySort.trace(:insertion, [3, 1, 2]).comparisons  # => 3
```

This gem does not override `Array#sort` and friends. Ruby's native sort is written in C and is much faster than
anything here, but it is not stable. Reach for ArraySort when you need a stable sort, want a specific algorithm's
guarantees, or want to learn and compare how the algorithms behave.

## Installation

Requires Ruby 3.3 or later. Add this line to your application's Gemfile:

```ruby
gem 'array-sort'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install array-sort

## Loading it

There are three ways to use ArraySort, depending on whether you want it to change `Array`.

**Patch `Array` everywhere.** This is what Bundler does by default for `gem 'array-sort'`, and what
`require 'array/sort'` does. Every array gets the sort methods.

```ruby
require 'array/sort'

[3, 1, 2].heap_sort # => [1, 2, 3]
```

**Refine `Array` in one file.** Load the gem without patching (in a Gemfile, `gem 'array-sort', require: 'array_sort'`),
then opt in per file with `using`. Code outside that file never sees the methods.

```ruby
require 'array_sort'
using ArraySort::Refinements

[3, 1, 2].heap_sort # => [1, 2, 3]
```

**Module functions.** Also available after `require 'array_sort'`, without touching `Array` at all. Each takes the
array as its first argument.

```ruby
require 'array_sort'

ArraySort.merge_sort([3, 1, 2])                # => [1, 2, 3]
ArraySort.quick_sort_by(%w[ccc a bb], &:size)  # => ["a", "bb", "ccc"]
ArraySort.insertion_sort!(array)               # sorts array in place
```

## Algorithms

Every algorithm `x` comes with `x_sort`, `x_sort!`, `x_sort_by` and `x_sort_by!`. Complexities are in big-O notation.
In the distribution sorts, k is the range of the keys (largest minus smallest) and w is the number of bytes needed for
that range.

### Simple sorts

| Algorithm             | Method                  | Best    | Average | Worst | Extra space | Stable |
| --------------------- | ----------------------- | ------- | ------- | ----- | ----------- | ------ |
| Bubble sort           | `bubble_sort`           | n       | n²      | n²    | 1           | Yes    |
| Cocktail shaker sort  | `cocktail_shaker_sort`  | n       | n²      | n²    | 1           | Yes    |
| Comb sort             | `comb_sort`             | n log n | n²/2ᵖ   | n²    | 1           | No     |
| Gnome sort            | `gnome_sort`            | n       | n²      | n²    | 1           | Yes    |
| Odd-even sort         | `odd_even_sort`         | n       | n²      | n²    | 1           | Yes    |
| Insertion sort        | `insertion_sort`        | n       | n²      | n²    | 1           | Yes    |
| Binary insertion sort | `binary_insertion_sort` | n log n | n²      | n²    | 1           | Yes    |
| Selection sort        | `selection_sort`        | n²      | n²      | n²    | 1           | No     |
| Cycle sort            | `cycle_sort`            | n²      | n²      | n²    | 1           | No     |
| Pancake sort          | `pancake_sort`          | n²      | n²      | n²    | 1           | No     |

### Efficient comparison sorts

| Algorithm       | Method            | Best    | Average | Worst   | Extra space | Stable |
| --------------- | ----------------- | ------- | ------- | ------- | ----------- | ------ |
| Merge sort      | `merge_sort`      | n       | n log n | n log n | n           | Yes    |
| Quicksort       | `quick_sort`      | n log n | n log n | n²      | log n       | No     |
| Heap sort       | `heap_sort`       | n log n | n log n | n log n | 1           | No     |
| Shell sort      | `shell_sort`      | n log n | ≈ n^1.3 | unknown | 1           | No     |
| Smoothsort      | `smooth_sort`     | n       | n log n | n log n | 1           | No     |
| Tree sort (AVL) | `tree_sort`       | n log n | n log n | n log n | n           | Yes    |
| Tournament sort | `tournament_sort` | n log n | n log n | n log n | n           | Yes    |

### Hybrid sorts

| Algorithm | Method       | Best    | Average | Worst   | Extra space | Stable |
| --------- | ------------ | ------- | ------- | ------- | ----------- | ------ |
| Introsort | `intro_sort` | n log n | n log n | n log n | log n       | No     |
| Timsort   | `tim_sort`   | n       | n log n | n log n | n           | Yes    |

### Distribution sorts

| Algorithm        | Method          | Best  | Average | Worst | Extra space | Stable |
| ---------------- | --------------- | ----- | ------- | ----- | ----------- | ------ |
| Counting sort    | `counting_sort` | n + k | n + k   | n + k | n + k       | Yes    |
| Radix sort (LSD) | `radix_sort`    | n·w   | n·w     | n·w   | n           | Yes    |
| Bucket sort      | `bucket_sort`   | n     | n       | n²    | n           | Yes    |

A few notes worth knowing:

 * **Quicksort** picks a random pivot, so its O(n²) worst case is vanishingly unlikely on any input, sorted and
   reversed arrays included.
 * **Introsort** (C++'s `std::sort`) is quicksort that falls back to heap sort when partitioning goes badly, and uses
   insertion sort for short ranges, so its worst case is O(n log n).
 * **Timsort** (Python's `sorted`, Java's object sort) finds runs that are already in order and merges them, so sorted,
   reversed and partly sorted data sort in close to linear time.
 * **Smoothsort** is a heap sort that takes linear time on sorted input, without extra memory.
 * **Comb sort's** average case depends on the number of passes p; in practice it is close to n log n. Shell sort's
   complexity with the gap sequence used here (Ciura's) is an open problem.
 * **Cycle sort** writes each element at most once, the minimum possible, at the cost of many comparisons.
 * **Gnome sort** uses the common variant where the gnome remembers where it left off.

You can also ask the gem about its algorithms:

```ruby
ArraySort.algorithms                # => [:binary_insertion, :bubble, :bucket, :cocktail_shaker, ...]
ArraySort.algorithm(:tim).stable?   # => true
ArraySort.algorithm(:tim).worst     # => "n log n"
```

## Usage

The methods behave like their native counterparts (see the
[Ruby documentation](https://docs.ruby-lang.org/en/master/Array.html#method-i-sort)):

```ruby
[3, 1, 2].insertion_sort                                   # => [1, 2, 3]
[3, 1, 2].merge_sort { |a, b| b <=> a }                    # => [3, 2, 1]
[[3, 3], [1, 4], [2, 6]].insertion_sort_by { |e| e[0] }    # => [[1, 4], [2, 6], [3, 3]]

array = [3, 1, 2]
array.smooth_sort!                                         # => [1, 2, 3], and array is now sorted
```

 * Without a bang, a new `Array` is returned and the receiver is left alone.
 * With a bang, the receiver is sorted in place and returned. If the comparison raises partway through, the receiver
   is left unchanged. Calling a bang method on a frozen array raises `FrozenError`.
 * A comparison block may return any number; only its sign matters. If two elements can't be compared (`<=>` or the
   block returns `nil`), an `ArgumentError` is raised.
 * The `_by` methods call their block exactly once per element, and return an `Enumerator` when called without one.

### Distribution sorts

Counting, radix and bucket sort never compare elements. Instead they place each element by a numeric key, which is
the element itself for `x_sort`, or whatever the block returns for `x_sort_by`. Counting and radix sort need Integer
keys (negative and arbitrarily large ones are fine); bucket sort takes any finite real number. Because they don't
compare, `x_sort` and `x_sort!` raise `ArgumentError` when given a comparison block.

```ruby
[10, -3, 2**70, 0].radix_sort        # => [-3, 0, 10, 1180591620717411303424]
[0.42, 0.07, 0.99, 0.5].bucket_sort  # => [0.07, 0.42, 0.5, 0.99]

people.radix_sort_by { |person| person[:age] } # stable, so people of the same age keep their order
```

Counting sort allocates a table as large as the range of the keys, so it raises `RangeError` for ranges above
max(2²⁰, 4n) rather than running out of memory. Radix sort is the better choice there.

### `Array#swap`

The gem also adds `swap`, which swaps two elements in place and returns the array:

```ruby
[1, 2, 3].swap(0, -1) # => [3, 2, 1]
```

## Tracing

`ArraySort.trace` sorts a copy of an array and records every comparison and every write the algorithm makes, which is
handy for visualizing algorithms or seeing how they differ.

```ruby
trace = ArraySort.trace(:insertion, [3, 1, 2])
trace.result       # => [1, 2, 3]
trace.comparisons  # => 3
trace.writes       # => 4
trace.events
# => [#<data ArraySort::Trace::Comparison left=3, right=1, result=1>,
#     #<data ArraySort::Trace::Write index=1, value=3>,
#     #<data ArraySort::Trace::Write index=0, value=1>,
#     #<data ArraySort::Trace::Comparison left=3, right=2, result=1>,
#     #<data ArraySort::Trace::Write index=2, value=3>,
#     #<data ArraySort::Trace::Comparison left=1, right=2, result=-1>,
#     #<data ArraySort::Trace::Write index=1, value=2>]

# Stream events as they happen
ArraySort.trace(:heap, [5, 1, 4, 2, 3]) { |event| puts event.inspect }
```

Replaying the writes onto a copy of `trace.input` reproduces the sort step by step. A swap shows up as two writes.
For example, sorting `[5, 1, 4, 2, 3]`:

| Algorithm | Comparisons | Writes |
| --------- | ----------- | ------ |
| Bubble    | 9           | 12     |
| Insertion | 9           | 10     |
| Selection | 10          | 8      |
| Cycle     | 31          | 5      |
| Merge     | 11          | 10     |
| Heap      | 9           | 16     |

Elements are compared with `<=>`. Distribution sorts make no comparisons at all.

## Benchmarks

`bundle exec rake bench` compares every algorithm with `Array#sort`. `SIZE`, `SHAPE` (`random`, `sorted`,
`reversed` or `few`) and `ALGORITHMS` (comma-separated names) are optional. For example:

    $ SIZE=10000 SHAPE=sorted ALGORITHMS=merge,tim,smooth bundle exec rake bench

## Type signatures

RBS signatures for the whole public API ship with the gem in `sig/array_sort.rbs`. They are generated from the
algorithm registry with `bundle exec rake sig`.

## Development

After checking out the repo, run `bin/setup` to install dependencies, then `bundle exec rake` to run the tests,
RuboCop and the RBS validation. You can also run `bin/console` for an interactive prompt that will allow you to
experiment.

Each algorithm lives in its own file in `lib/array_sort/algorithms/` and registers itself with its name, stability
and complexity. Registering it is all it takes for it to get its four `Array` methods, module functions, refinement,
tracing, benchmark and type signatures, and to run against the full shared test suite. To add one:

1. Add `lib/array_sort/algorithms/x_sort.rb` and require it from `lib/array_sort.rb`. A comparison sort implements
   `call(array, compare)`, a distribution sort `call(array, key)`; both sort `array` in place and may only change it
   with single-element assignment (`array[i] = value`), which is what makes tracing work.
2. Add its row to the tables above (a test checks that they match the registry).
3. Run `bundle exec rake sig` to regenerate the type signatures.

### Releasing

Releases are published from GitHub Actions with RubyGems trusted publishing, so no API key is needed. Once, on
rubygems.org, add a trusted publisher for this gem (repository `foxhatleo/array-sort`, workflow `release.yml`,
environment `release`). Then, for each release, bump `ArraySort::VERSION` and the CHANGELOG, merge to `master`, and
run the **Release** workflow from the Actions tab. It runs the tests, pushes the gem and tags the release.

## Contributing

Bug reports and pull requests are welcome on GitHub at
[https://github.com/foxhatleo/array-sort](https://github.com/foxhatleo/array-sort). This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to adhere to the
[Contributor Covenant](https://www.contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
