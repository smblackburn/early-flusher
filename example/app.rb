require 'rubygems'
require 'sinatra'
require '../lib/sinatra/early_flusher'

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