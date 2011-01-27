# Dead simple plugin to provide a simple DSL for early flushing in Sinatra apps

Example Usage:

  get '/flushall' do
    # call out earlyflush helper
    earlyflush do |page|
      # build the headers js, css, etc.
      page.flush do
        '<!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <style>body { background-color: black; color: white; }</style>
            <title>Sample page flushing</title>
          </head>
        '
      end
      page.flush do
        sleep(1) # pretend we are doing slow things, like calling a service
        '<body>
          Some Body content
        </body>
        '
      end
      page.flush do
        sleep(1) # pretend we are doing slow things, like calling a service
        '<body>
          And....some more
        </body>
        '
      end
      page.flush do
        sleep(1) # pretend we are doing slow things, like calling a service
        '<body>
          End
        </body>
        '
      end
    end
  end

# Testing Requirements
Run the following on the root directory, to install the dependencies (they are only needed for testing purposes)

 `bundle install`

