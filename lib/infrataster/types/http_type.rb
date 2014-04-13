require 'infrataster/types/base_type'
require 'uri'

module Infrataster
  module Types
    class HttpType < BaseType
      Error = Class.new(StandardError)

      attr_reader :uri

      def initialize(url_str)
        @uri = URI.parse(url_str)
        unless %w!http https!.include?(@uri.scheme)
          raise Error, "The provided url, '#{@uri}', is not http or https."
        end
      end

      def to_s
        "http '#{@uri}'"
      end
    end
  end
end

