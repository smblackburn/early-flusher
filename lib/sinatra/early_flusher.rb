require 'sinatra/base'
require 'thread'

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
        @lock = Mutex.new
      end

      def each
        p_blocks = []
        
        self.blocks.each do |block|
          # Add parallel blocks to the parallel block array
          if block.parallel
            p_blocks << block
          end
          
          # When we encounter a non-parallel block or the
          # last block, execute all blocks in the parallel
          # block array
          if !block.parallel || block == blocks.last
            threads = []
            p_blocks.each do |p_block|
              threads << Thread.new do
                res = p_block.proc.call(self)
                @lock.synchronize do
                  yield res + NEWLINE_SEPARATOR
                end
              end
            end

            threads.each do |thread|
              thread.join
            end
            
            p_blocks = []
          end
          
          # Execute non-parallel blocks immediately  
          if !block.parallel
            yield block.proc.call(self) + NEWLINE_SEPARATOR
          end
        end
      end

      def flush(&block)
        self.blocks << FlushBlock.new(false,Proc.new(&block))
      end
      
      def pflush(&block)
        self.blocks << FlushBlock.new(true,Proc.new(&block))
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
  
  # Wraps a proc with parallel execution flag.
  # To execute the proc in parallel with others,
  # set parallel = true
  class FlushBlock
    attr_accessor :parallel
    attr_accessor :proc
    
    def initialize(is_parallel,proc)
      self.parallel = is_parallel
      self.proc = proc
    end
  end

  # Add the helper to sinatra base
  helpers EarlyFlusherHelper
end
