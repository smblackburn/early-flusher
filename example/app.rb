require 'rubygems'
require 'sinatra'
require '../lib/sinatra/early_flusher'
require '../lib/sinatra/big_pipe'

get '/crazy' do
  # call out earlyflush helper
  earlyflush do |page|
    page.flush do
      sleep(3) # let's pretend we are doing something slow
      'Here’s to the crazy ones. The misfits. The rebels. The troublemakers. The round pegs in the square holes.'
    end
    page.flush do
      sleep(3) # let's pretend we are doing something slow
      "The ones who see things differently. They’re not fond of rules. And they have no respect for the status quo. You can quote them, disagree with them, glorify or vilify them."
    end
    page.flush {
      sleep(3) # let's pretend we are doing something slow
      "About the only thing you can’t do is ignore them. Because they change things. They invent. They imagine. They heal. They explore. They create. They inspire. They push the human race forward."
    }
    page.flush do
      sleep(3) # let's pretend we are doing something slow
      "Maybe they have to be crazy."
    end
    page.flush do
      sleep(3) # let's pretend we are doing something slow
      "How else can you stare at an empty canvas and see a work of art? Or sit in silence and hear a song that’s never been written? Or gaze at a red planet and see a laboratory on wheels?"
    end
    page.flush do
      sleep(3) # let's pretend we are doing something slow
      "While some see them as the crazy ones, we see genius."
    end
    page.flush do
      sleep(3) # let's pretend we are doing something slow
      "Because the people who are crazy enough to think they can change the world, are the ones who do."
    end
  end
end

get '/parallel' do
  # This will execute the first three blocks in order,
  # then the next three in parallel, and finally the
  # last block will execute
  earlyflush do |page|
    page.flush do
      sleep(3)
      "1 - serial<br>"
    end
    page.flush do
      sleep(3)
      "2 - serial<br>"
    end
    page.flush do
      sleep(3)
      "3 - serial<br>"
    end
    page.pflush do
      sleep(3)
      "4 - parallel<br>"
    end
    page.pflush do
      sleep(3)
      "5 - parallel<br>"
    end
    page.pflush do
      sleep(3)
      "6 - parallel<br>"
    end
    page.flush do
      sleep(3)
      "7 - serial<br>"
    end
  end
end

get '/bigpipe' do
  big_pipe_head = %[
  <html>
    <head>
      <meta charset="utf-8">
      <style>
        body { background-color: white; color: black; text-align: center; }
        div { border-style: solid; border-width: 1px; position: absolute;}
      </style>
      <script>
        function big_pipe(json)
        {
            var div_to_set = document.getElementById(json.div_id);
            div_to_set.innerHTML = json.markup;
        }
      </script>
      <title>BigPipe Fun!</title>
    </head>
    <body>
      <div id='header' style='width: 980px; height: 65px; left: 10px; top: 10px;'>
      </div>
      <div id='left-rail' style='width: 150px; height: 800px; left: 10px; top: 80px;'>
      </div>
      <div id='main' style='width: 670px; height: 800px; left: 165px; top: 80px;'>
      </div>
      <div id='right-rail' style='width: 150px; height: 800px; left: 840px; top: 80px;'>
      </div>]
      
  big_pipe_tail = %[
    </body>
  <html>]
  
  bigpipe do |pipe|
    pipe.first_flush do
      big_pipe_head
    end
    
    pipe.pagelet('header') do
      sleep(1)
      '<strong>BigPiped Header!</strong>'
    end
    
    pipe.pagelet('left-rail') do
      sleep(2)
      'Left-Rail'
    end
    
    pipe.pagelet('right-rail') do
      sleep(2)
      'Right-Rail'
    end
    
    pipe.pagelet('main') do
      sleep(3)
      'Main Content'
    end
    
    pipe.last_flush do
      big_pipe_tail
    end
  end
end
