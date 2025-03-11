# frozen_string_literal: true

require 'rspec'
require_relative '../loader'

RSpec.describe ExternalSort do

  let!(:generated_data) { DataGenerator.generate_csv(100) }

  after do
    path = Dir.glob(File.dirname(generated_data)).first
    FileUtils.rm_rf(path) if Dir.exist?(path)
  end

  subject { ExternalSort.new(generated_data, 'test_transaction.csv') }

  it 'serialized data transaction' do
    raw_transaction = File.foreach(generated_data).first
    ins = subject.parse_line(raw_transaction)

    expect(ins.class).to eq(Entity::TransactionCsv)
    expect(ins.user_id).to start_with('user')
    expect(ins.amount).to be_between(10, 10000)
    expect(ins.transaction_id).not_to be_empty
  end

  it 'methods call ordered' do
    allow(subject).to receive(:sort).and_call_original

    subject.sort

    expect(subject).to have_received(:sort).ordered
  end

  it 'sorting by temporary file divided into parts' do
    init_sort = ExternalSort.new(generated_data, 'test_transaction.csv')
    init_sort.sort
    
    expect(File.basename(init_sort.temp_files.first)).to start_with('chunk')
    expect(init_sort.temp_files.first.length).not_to be(0)
  end


  context 'sorting data' do
    let!(:sorter) { subject.sort }

    it 'sorted file with transactions by desc and return output file' do

      transactions = File.readlines(subject.output_file).first(3)
      expect(transactions.length).to be >= 3

      expect(subject.parse_line(transactions[0]).amount).to be >= subject.parse_line(transactions[1]).amount
      expect(subject.parse_line(transactions[1]).amount).to be >= subject.parse_line(transactions[2]).amount
    end
  end
end
