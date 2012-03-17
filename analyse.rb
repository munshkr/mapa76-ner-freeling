#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'padrino-helpers'

$LOAD_PATH << './lib'

require 'document'

DOCUMENTS_PATH = File.join(settings.public_folder, 'docs')



helpers do
  register Padrino::Helpers

  def tagged_document_html(document)
    html = ''
    cur = 0
    document.tagged_tokens.each do |token|
      html << document.text[cur ... token.offset]
      token_class = (token.named_entity? or token.date?) ? "ned #{token.class}" : nil
      html << content_tag(:span, token.orig_form, :class => token_class)
      cur = token.offset + token.form.size
    end
    simple_format(html)
  end
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
