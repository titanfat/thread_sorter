# frozen_string_literal: true

require_relative 'loader'
require 'pathname'

data_generate = DataGenerator.generate_csv(300)
sorter = ExternalSort.new(data_generate, 'sorted_transactions.csv')
sorter.sort
