# frozen_string_literal: true

require 'zeitwerk'
require 'byebug'
require_relative 'data_generator'
require_relative 'external_sort'
require_relative 'external_sort_actor'
require_relative 'external_sort_async'
require_relative 'entity/transaction'
require_relative 'entity/transaction_csv'
require_relative 'engine'

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__)
loader.setup
