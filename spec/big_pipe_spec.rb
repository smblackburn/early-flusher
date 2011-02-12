require File.dirname(__FILE__) + '/spec_helper'

describe Sinatra::BigPipeHelper::BigPipe do
  before(:each) do
    @big_pipe = BigPipe.new do |page|
      page.first_flush { "Head html" }
      page.pagelet('div_1') { "Content html" }
      page.pagelet('div_2') { "More content html"}
      page.last_flush { "Tail html" }
    end
  end

  it "should have a newline separator for the chunks" do
    BigPipe::NEWLINE_SEPARATOR.should eql("\r\n")
  end

  it "should not fail if no block is specified" do
    big_pipe = BigPipe.new
    big_pipe.class.should eql(Sinatra::BigPipeHelper::BigPipe)
    big_pipe.should respond_to(:each)
  end

  it "should have a pagelets attribute that stores the pagelet chunks" do
    @big_pipe.pagelets.length.should eql(2)
  end

  it "should respond to pagelet and add the pagelet to the pagelets list" do
    big_pipe = BigPipe.new
    big_pipe.should respond_to(:pagelet)
    block = Proc.new do
      "Some HTML"
    end
    big_pipe.pagelet('div_1',&block)
    big_pipe.pagelets.length.should eql(1)
    big_pipe.pagelets.first.proc.should eql(block)
  end

  it "should add a newline to all flushes" do
    big_pipe = BigPipe.new do |page|
      page.first_flush { "Some html" }
      page.last_flush { "Some html" }
    end
    big_pipe.each do |block|
      block.should eql("Some html" + BigPipe::NEWLINE_SEPARATOR)
    end
  end
  
  it "should add correct script and newline to all pagelet flushes" do
    big_pipe = BigPipe.new do |page|
      page.pagelet("div_1") do
        "Some html"
      end
    end
    big_pipe.each do |block|
      block.should eql(%[<script>var obj={'div_id':"div_1",'markup':"Some html"};big_pipe(obj);</script>] + BigPipe::NEWLINE_SEPARATOR)
    end
  end
  
  it "should flush in this order: first_flush, pagelets, js includes, last flush" do
    big_pipe = BigPipe.new do |page|
      page.js_include("test.js")
      
      page.last_flush do
        "last flush"
      end
      
      page.first_flush do
        "first flush"
      end
      
      page.pagelet("div_1") do
        "pagelet"
      end
    end
    blocks = []
    big_pipe.each do |block|
      blocks << block
    end
    blocks[0].should eql("first flush" + BigPipe::NEWLINE_SEPARATOR)
    blocks[1].should eql(%[<script>var obj={'div_id':"div_1",'markup':"pagelet"};big_pipe(obj);</script>] + BigPipe::NEWLINE_SEPARATOR)
    blocks[2].should eql(%[<script type="text/javascript" src="test.js"></script>] + BigPipe::NEWLINE_SEPARATOR)
    blocks[3].should eql("last flush" + BigPipe::NEWLINE_SEPARATOR)
  end

  describe "Sinatra Helper" do
    include Rack::Test::Methods

    def app
      @app ||= Sinatra::Application
    end

    # Dummy action for testing
    get '/' do
      bigpipe do |page|
        page.first_flush do
          "Some HTML"
        end
      end
    end

    it "should have a helper method" do
      @app.should respond_to(:bigpipe)
    end

    it "should have a helper method and set the correct header" do
      get '/'
      last_response.status.should eql(200)
      last_response.body.should eql("Some HTML"+EarlyFlush::NEWLINE_SEPARATOR)
      last_response.headers.should eql({"Content-Transfer-Encoding"=>"chunked", "Content-Type"=>"text/html;charset=utf-8"})
    end
  end
end
