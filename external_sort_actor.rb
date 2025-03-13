# frozen_string_literal: true

require 'tempfile'
require 'logger'

module ThreadSorter
  class ExternalSortActor
    MAX_THREADS = 4
    @@logger = Logger.new(STDOUT)

    attr_reader :output_file

    def initialize(file_path, output_path = 'sorted_transactions', pool_size = 100)
      @file_path = file_path

      dir_path = File.dirname file_path
      @output_file = File.join dir_path, output_path

      @pool_size ||= pool_size
      @actor = Ractor.new do
        temp_files = []
        loop do
          msg = Ractor.receive
          case msg
          when :get_files then Ractor.yield temp_files
          else temp_files << msg
          end
        end
      end
    end

    def sort
      process_chunks { save_chunk(merge_sort _1) }
      merge_chunks
      @actor.send(:get_files)
      @actor.take.each(&:unlink)
    end

    def merge_sort(arr)
      return arr if arr.size <= 1

      mid = arr.size / 2
      left = merge_sort(arr[0...mid])
      right = merge_sort(arr[mid..])
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
      @actor.send temp
    rescue StandardError => e
      @@logger.info temp.inspect, e unless temp
    end

    def parse_line(line)
      timestamp, transaction_id, user_id, amount = line.strip.split(',')
      ThreadSorter::Entity::TransactionCsv.new timestamp, transaction_id, user_id, amount
    end

    private

    def process_chunks
      threads = []
      File.foreach(@file_path).each_slice(@pool_size) do |lines|
        chunk = lines.map { parse_line _1 }
        threads << Thread.new { yield chunk }
        sleep(0.02) while threads.count(&:alive?) >= MAX_THREADS
      end
        threads.each(&:join)
    end

    def merge_chunks
      @actor.send(:get_files)
      temp_files = @actor.take
      temp_handler = temp_files.map { { file: _1, handler: File.open(_1.path, 'r') } }
      curr_transaction = temp_handler.map do
        line = _1[:handler].gets
        line ? { transaction: parse_line(line), **_1 } : nil
      end.compact

      file = File.open(@output_file, 'w')
      until curr_transaction.empty?
        max_entry = curr_transaction.max_by { _1[:transaction].amount }
        file.puts(max_entry[:transaction].to_format)

        next_line = max_entry[:handler].gets
        if next_line
          max_entry[:transaction] = parse_line(next_line)
        else
          max_entry[:handler].close
          curr_transaction.delete(max_entry)
        end
      end
    end
  end
end
