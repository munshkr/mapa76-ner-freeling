#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'sinatra'

require 'ner/freeling/analyzer'


helpers do
  include Rack::Utils
  alias_method :h, :escape
end


get '/' do
  @files = Hash[Dir["#{settings.public_folder}/docs/*.txt"].sort.map { |path|
    [File.basename(path), path]
  }]
  erb :index
end

get '/analyse' do
  @basename = File.basename(params[:f])
  @anal = NER::FreeLing::Analyzer.new(open(params[:f]))                                                                                                                            
  @sentences = @anal.sentences
  erb :analyse
end

post '/analyse' do
  'TODO'
end
