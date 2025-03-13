# frozen_string_literal: true

require 'tempfile'
require 'logger'
require 'async/semaphore'
require 'async'

module ThreadSorter
  class ExternalSortAsync
    MAX_THREADS = 4
    @@logger = Logger.new(STDOUT)

    attr_reader :output_file, :temp_files

    def initialize(file_path, output_path = 'sorted_transactions', pool_size = 100)
      @file_path = file_path

      dir_path = File.dirname file_path
      @output_file = File.join dir_path, output_path

      @pool_size ||= pool_size
      @async = Async::Semaphore.new(1)
      @temp_files = []
    end

    def sort
      Async do
        process_chunks
        merge_chunks
      end.wait
    end

    def merge_sort(arr)
      return arr if arr.size <= 1

      mid = arr.size / 2
      left, right = merge_sort(arr[0...mid]), merge_sort(arr[mid..])
      merge(left, right)
    end

    def merge(left, right)
      return left if right.empty?
      return right if left.empty?

      if left[0].amount >= right[0].amount
        [left[0]].concat merge(left[1..], right)
      else
        [right[0]].concat merge(left, right[1..])
      end
    end

    # chunk в виде csv строк
    def save_chunk(chunk)
      temp = Tempfile.new(['chunk'], Dir.tmpdir)
      chunk.each { temp.write "#{_1.to_format}" }
      temp.flush
      @async.async { @temp_files << temp }
    rescue StandardError => e
      @@logger.info temp.inspect, e unless temp
    end

    def parse_line(line)
      timestamp, transaction_id, user_id, amount = line.strip.split(',')
      ThreadSorter::Entity::TransactionCsv.new timestamp, transaction_id, user_id, amount
    end

    private

    def process_chunks
      Async do |task|
        semaphore = Async::Semaphore.new(MAX_THREADS)
        File.foreach(@file_path).each_slice(@pool_size) do |lines|
          task.async(semaphore) do
            chunk = lines.map { parse_line _1 }
            save_chunk(merge_sort(chunk))
          end
        end
      end.wait
    end

    def merge_chunks
      temp_handler = @temp_files.map { [_1, _1.open] }.to_h
      curr_transaction = temp_handler.map do |file, f|
        line = f.gets
        line ? { transaction: parse_line(line), file: File.open(file.path) } : nil
      end.compact


      file = File.open(@output_file, 'w')
      begin
        until curr_transaction.empty?
          max_entry = curr_transaction.max_by { _1[:transaction].amount }
          file.puts(max_entry[:transaction].to_format)

          next_line = max_entry[:file].gets
          if next_line
            max_entry[:transaction] = parse_line(next_line)
          else
            max_entry[:file].close
            curr_transaction.delete(max_entry)
          end
        end
      ensure
        file&.close
      end
    end
  end
end