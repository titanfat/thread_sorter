# frozen_string_literal: true

require 'zeitwerk'
require 'byebug'

loader = Zeitwerk::Loader.new
loader.push_dir(__dir__)
loader.setup
