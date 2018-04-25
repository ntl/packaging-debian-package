ENV['CONSOLE_DEVICE'] ||= 'stdout'
ENV['LOG_LEVEL'] ||= '_min'

puts RUBY_DESCRIPTION

require_relative '../init'

require 'test_bench'; TestBench.activate

require_relative './fixtures/fixtures_init'

require 'pp'
require 'securerandom'

require 'packaging/debian/package/controls'

include Packaging::Debian

Controls = Packaging::Debian::Package::Controls
