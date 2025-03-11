# frozen_string_literal: true

require 'csv'

module ThreadSorter
  module Entity
    class TransactionCsv < Transaction
      attr_reader :timestamp, :transaction_id, :user_id, :amount

      def initialize(*attrs)
        super(*attrs)
      end

      def to_format
        [@timestamp, @transaction_id, @user_id, @amount].to_csv
      end

      def self.from_file(line)
        data = CSV.parse_line(line)
        new(*data)
      end

      def to_s
        "#{@timestamp},#{@transaction_id},#{@user_id},#{@amount}"
      end
    end
  end
end