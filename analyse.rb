#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'padrino-helpers'
require 'mongoid'

Mongoid.load!(File.join(File.dirname(__FILE__), 'mongoid.yml'))
Mongoid.logger = Logger.new($stdout)

$LOAD_PATH << './lib'

require 'document'

DOCUMENTS_PATH = File.join(settings.public_folder, 'docs')


helpers do
  register Padrino::Helpers

  def tagged_document_html(document)
=begin
    html = ''
    cur = 0
    document.tagged_tokens.each do |token|
      html << document.content[cur ... token.offset]
      token_class = 'tk'
      token_class << " ne #{token.class}" if token.named_entity? or token.date?
      html << content_tag(:span, token.orig_form, :class => token_class)
      cur = token.offset + token.form.size
    end
    simple_format(html)
=end
    simple_format(document.content)
  end
end


get '/' do
  @files = Dir[File.join(DOCUMENTS_PATH, '*.txt')].sort.map do |path|
    File.basename(path)
  end
  erb :index
end

get '/analyse' do
  @document = Document.find_or_initialize_by(:filename => params[:f])
  if @document.new?
    @document.content = open(File.join(DOCUMENTS_PATH, params[:f])).read
    @document.save
  end
  if not @document.analyzed?
    @document.analyze!
    @document.save
  end

  @tokens = @document.tokens
  @named_entities = @document.named_entities

  erb :analyse
end

post '/analyse' do
  'TODO'
end
