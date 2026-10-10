# Changelog

All notable changes to this project are documented in this file. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-10

The public API (`*_sort`, `*_sort!`, `*_sort_by`, `*_sort_by!` and `Array#swap`) is unchanged, but several of its
behaviors were wrong and have been fixed, which is why this is a major release. If you relied on any of the old
behavior listed under "Changed", please check your code.

### Fixed

- `merge_sort` and `quick_sort` (and their `!`/`_by` variants) only applied a custom comparison block at the top level
  of the recursion, so sorting with a block, e.g. in descending order, usually returned a wrongly ordered array.
- `insertion_sort` and `heap_sort` treated only exactly `1`/`-1` as "greater"/"less", so a block returning other
  numbers (like `a - b`) produced unsorted output.
- `quick_sort` raised `SystemStackError` on large sorted arrays (about 10,000 elements) and took quadratic time on
  sorted or reverse-sorted input.
- Comparing incomparable elements raised `NoMethodError` instead of `ArgumentError`, as `Array#sort` does.
- `Array#swap` with an out-of-range index silently grew the array and filled it with `nil`s. It now raises
  `IndexError`.

### Changed

- Ruby 3.2 or later is required.
- Bang methods check for a frozen receiver before doing any work, so they raise `FrozenError` even if the array is
  already sorted, and without calling the block.
- Bang methods leave the receiver untouched if the comparison raises partway through, like `Array#sort!`.
- The `_by` methods call their block exactly once per element (previously up to twice per comparison).
- Non-bang methods always return a plain `Array`, even for subclasses of `Array`, like `Array#sort`.
- Rewrote merge sort and quicksort to stop allocating new arrays at every level of recursion: merge sort now merges
  with indices and a single scratch buffer, and quicksort sorts in place with a random pivot and three-way
  partitioning. Insertion sort shifts elements instead of swapping them.
- The private helper methods the gem used to add to `Array` (`sort_compare`, `become_clone_of`, `heapify`,
  `sift_down` and others) were removed. The algorithms now live in the `ArraySort` module and no longer add anything
  to `Array` beyond the public sort methods and `swap`.
- Enumerators returned by the `_by` methods now report their `size`.

### Added

- GitHub Actions CI testing Ruby 3.2, 3.3, 3.4 and 4.0, and running RuboCop.
- RubyGems metadata (source, changelog and issue tracker links) and MFA requirement for publishing.

### Removed

- Travis CI configuration.
- `bundler` as a development dependency in the gemspec. Development dependencies now live in the `Gemfile`.

## [0.1.1] - 2018-05-11

- Initial public release with bubble sort, heap sort, insertion sort, merge sort and quicksort.

[1.0.0]: https://github.com/foxhatleo/array-sort/compare/0c3220b...v1.0.0
[0.1.1]: https://github.com/foxhatleo/array-sort/commit/0c3220b
