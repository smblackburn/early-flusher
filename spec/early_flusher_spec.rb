require File.dirname(__FILE__) + '/spec_helper'

describe Sinatra::EarlyFlusherHelper::EarlyFlush do
  before(:each) do
    @early_flusher = EarlyFlush.new do |page|
      page.flush { "Some html" }
      page.flush { "Even some more html" }
    end
  end

  it "should have a newline separator for the chunks" do
    EarlyFlush::NEWLINE_SEPARATOR.should eql("\r\n")
  end

  it "should not fail if no block is specified" do
    early_flusher = EarlyFlush.new
    early_flusher.class.should eql(Sinatra::EarlyFlusherHelper::EarlyFlush)
    early_flusher.should respond_to(:each)
  end

  it "should have a blocks attribute that stores the page chunks" do
    @early_flusher.blocks.length.should eql(2)
  end

  it "should respond to flush and add the block to the blocks list" do
    early_flusher = EarlyFlush.new
    early_flusher.should respond_to(:flush)
    block = Proc.new do
      "Some HTML"
    end
    early_flusher.flush(&block)
    early_flusher.blocks.length.should eql(1)
    early_flusher.blocks.first.should eql(block)
  end

  it "should add a newline to all flushes" do
    early_flusher = EarlyFlush.new do |page|
      page.flush { "Some html" }
    end
    early_flusher.each do |block|
      block.should eql("Some html" + EarlyFlush::NEWLINE_SEPARATOR)
    end
  end

  describe "Sinatra Helper" do
    include Rack::Test::Methods

    def app
      @app ||= Sinatra::Application
    end

    # Dummy action for testing
    get '/' do
      earlyflush do |page|
        page.flush do
          "Some HTML"
        end
      end
    end

    it "should have a helper method" do
      @app.should respond_to(:earlyflush)
    end

    it "should have a helper method and set the correct header" do
      get '/'
      last_response.status.should eql(200)
      last_response.body.should eql("Some HTML"+EarlyFlush::NEWLINE_SEPARATOR)
      last_response.headers.should eql({"Content-Transfer-Encoding"=>"chunked", "Content-Type"=>"text/html;charset=utf-8"})
    end
  end
end
