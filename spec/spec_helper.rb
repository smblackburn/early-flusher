require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'lib/sinatra/early_flusher'
require 'lib/sinatra/big_pipe'

include Sinatra::EarlyFlusherHelper
include Sinatra::BigPipeHelper