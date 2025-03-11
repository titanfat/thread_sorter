# frozen_string_literal: true

require 'date'
require 'csv'
require_relative 'loader'
require 'fileutils'

class DataGenerator
  class << self

    def generate_csv(num_records)
      data = []

      num_records.times do
        timestamp = DateTime.now.strftime('%Y-%m-%dT%H:%M:%SZ')
        transaction_id = "txn#{rand(10..10_000)}"
        user_id = "user#{rand(1..1000)}"
        amount = format('%.2f', rand(100.0..10_000.0))
        data << Entity::TransactionCsv.new(timestamp, transaction_id, user_id, amount).to_format
      end

      file_path = mkdir_files('csv')
      File.write(file_path, data.join, mode: 'w')

      file_path
    end

    def mkdir_files(type)
      dir = FileUtils.mkdir_p("sorting_data/#{type}-#{Time.now.strftime('%m%d%H%M')}")
      File.join(dir, "csv_data#{Time.now.strftime('%m%d%H%M')}.csv")
    end
  end
end
