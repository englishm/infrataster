require 'infrataster/types/base_type'
require 'uri'

module Infrataster
  module Types
    class CapybaraType < BaseType
      Error = Class.new(StandardError)

      attr_reader :uri

      def initialize(url)
        @uri = URI.parse(url)
      end

      def to_s
        "capybara '#{@uri}'"
      end
    end
  end
end

