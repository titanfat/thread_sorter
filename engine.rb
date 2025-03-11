# frozen_string_literal: true

require_relative 'loader'
require 'pathname'
require 'benchmark'

module ThreadSorter

  def self.run
    data_generate = ThreadSorter::DataGenerator.generate_csv(300)
    sorter = ThreadSorter::ExternalSort.new(data_generate, 'sorted_transactions.csv')
    sorter.sort
  end

  # def run_from_input(path, output_path, poll)
  #   sorter = ExternalSort.new(path, output_path, poll)
  #   sorter.sort
  # end
end

ThreadSorter.run
