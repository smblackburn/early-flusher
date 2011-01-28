require 'sinatra/base'

module Sinatra
  module EarlyFlusherHelper
    # This class wraps the block based calls
    #
    # example usage:
    #  EarlyFlush.new do |page|
    #    page.flush { "Some content" }
    #    page.flush { "Some more content" }
    #  end
    class EarlyFlush
      attr_accessor :blocks

      NEWLINE_SEPARATOR = "\r\n"

      def initialize(&block)
        self.blocks = []
        block.call(self) if block
      end

      def each
        self.blocks.each { |b| yield b.call(self) + NEWLINE_SEPARATOR }
      end

      def flush(&block)
        self.blocks << Proc.new(&block)
      end
    end

    #
    # Sinatra Helper method
    #
    def earlyflush(&block)
      headers "Transfer-Encoding" => "chunked"
      EarlyFlush.new(&block)
    end
  end

  # Add the helper to sinatra base
  helpers EarlyFlusherHelper
end
