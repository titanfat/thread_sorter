# frozen_string_literal: true

require_relative 'loader'
require 'pathname'
require 'benchmark'

module ThreadSorter

  def self.run
    ThreadSorter::ExternalSort.new(generate_csv, 'sorted_transactions.csv').sort
  end

  def self.run_ractor
    ThreadSorter::ExternalSortActor.new(generate_csv, 'sorted_transactions.csv').sort
  end

  def self.run_async
    ThreadSorter::ExternalSortAsync.new(generate_csv, 'sorted_transactions.csv').sort
  end

  def self.run_from_input(path, output_path, poll)
    ExternalSort.new(path, output_path, poll).sort
  end

  def self.generate_csv
    ThreadSorter::DataGenerator.generate_csv(300)
  end
end

# Benchmark.bm { |x| x.report { ThreadSorter.run } }
ThreadSorter.run
