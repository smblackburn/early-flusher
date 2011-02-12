require 'sinatra/base'
require 'thread'

module Sinatra
  module BigPipeHelper
    # This class wraps the block based calls with 
    # a BigPipe-like syntax
    #
    # example usage:
    #  bigpipe do |page|
    #    pipe.js_include('test.js')
    #
    #    pipe.first_flush do
    #      header, css includes, bigpipe js, basic div layout
    #    end
    #
    #    pipe.pagelet('div-id')
    #      service calls, pagelet content...
    #    end
    #
    #    pipe.last_flush
    #      close body and html tags
    #    end
    #  end
    #
    # example bigpipe js (should be included in html head):
    #  <script>
    #    function big_pipe(json)
    #    {
    #        var div_to_set = document.getElementById(json.div_id);
    #        div_to_set.innerHTML = json.markup;
    #    }
    #  </script>
    class BigPipe
      attr_accessor :pagelets
      attr_accessor :scripts
      attr_accessor :first_block
      attr_accessor :last_block

      NEWLINE_SEPARATOR = "\r\n"

      def initialize(&block)
        self.pagelets = []
        self.scripts = []
        block.call(self) if block
        @lock = Mutex.new
      end

      def each

        yield self.first_block.call(self) + NEWLINE_SEPARATOR if self.first_block

        threads = []
        self.pagelets.each do |pagelet|
          threads << Thread.new do
            res = %[<script>var obj={'div_id':"#{pagelet.div_id}",'markup':"#{pagelet.proc.call(self)}"};big_pipe(obj);</script>]
            @lock.synchronize do
              yield res + NEWLINE_SEPARATOR
            end
          end
        end

        threads.each do |thread|
          thread.join
        end
        
        self.scripts.each do |script|
          yield %[<script type="text/javascript" src="#{script}"></script>] + NEWLINE_SEPARATOR
        end

        yield self.last_block.call(self) + NEWLINE_SEPARATOR if self.last_block
      end

      def first_flush(&block)
        self.first_block = block
      end

      def last_flush(&block)
        self.last_block = block
      end

      def pagelet(div_id, &block)
        self.pagelets << Pagelet.new(div_id, block)
      end
      
      def js_include(js_file)
        self.scripts << js_file
      end
    end

    class Pagelet
      attr_accessor :div_id
      attr_accessor :proc

      def initialize(div_id, block)
        self.div_id = div_id
        self.proc = Proc.new(&block)
      end
    end

    #
    # Sinatra Helper method
    #
    def bigpipe(&block)
      headers "Content-Transfer-Encoding" => "chunked"
      BigPipe.new(&block)
    end
  end
  
  # Add the helper to sinatra base
  helpers BigPipeHelper
end
