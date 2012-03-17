#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'sinatra'

$LOAD_PATH << './lib'

require 'document'

DOCUMENTS_PATH = File.join(settings.public_folder, 'docs')


helpers do
  include Rack::Utils
  alias_method :h, :escape
end


get '/' do
  @files = Dir[File.join(DOCUMENTS_PATH, '*.txt')].sort.map do |path|
    File.basename(path)
  end
  erb :index
end

get '/analyse' do
  @document = Document.new(open(File.join(DOCUMENTS_PATH, params[:f])).read)
  erb :analyse
end

post '/analyse' do
  'TODO'
end
