# Dead simple plugin to provide a simple DSL for early flushing in Sinatra apps

Example Usage:

  get '/' do
    earlyflush do |page|

      page.flush do
        "Some HTML"
      end

      page.flush do
        "Even Some More HTML"
      end
    end
  end

# Testing Requirements
Run the following on the root directory, to install the dependencies (they are only needed for testing purposes)

 `bundle install`

