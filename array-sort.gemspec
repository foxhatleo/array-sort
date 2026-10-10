# frozen_string_literal: true

require_relative 'lib/array/sort/version'

Gem::Specification.new do |spec|
  spec.name          = 'array-sort'
  spec.version       = ArraySort::VERSION
  spec.authors       = ['Leo Liang']
  spec.email         = ['developer@leoliang.com']

  spec.summary       = 'Implementations of popular sorting algorithms for Arrays.'
  spec.description   = 'Adds bubble sort, heap sort, insertion sort, merge sort and quicksort to Array, ' \
                       'with the same interface as Array#sort, #sort!, #sort_by and #sort_by!.'
  spec.homepage      = 'https://github.com/foxhatleo/array-sort'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2'

  spec.metadata = {
    'source_code_uri' => spec.homepage,
    'changelog_uri' => "#{spec.homepage}/blob/master/CHANGELOG.md",
    'bug_tracker_uri' => "#{spec.homepage}/issues",
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir['lib/**/*.rb', 'CHANGELOG.md', 'LICENSE.txt', 'README.md']
  spec.require_paths = ['lib']
end
