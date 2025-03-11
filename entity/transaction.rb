# frozen_string_literal: true

module Entity
  class Transaction
    include Comparable

    def initialize(timestamp, transaction_id, user_id, amount)
      @timestamp = timestamp
      @transaction_id = transaction_id
      @user_id = user_id
      @amount = amount.to_f
    end

    def to_format
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def self.from_file
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end

    def to_s
      raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
    end
  end
end
