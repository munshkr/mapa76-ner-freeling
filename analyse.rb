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
    tokens_per_pos = Hash[document.tokens.map { |token|
      [token[:pos], token.merge(:html => content_tag(:span, token[:form], :class => 'tk', 'data-pos' => token[:pos]))]
    }]

    document.named_entities.each do |ne|
      first = ne.tokens.min {|a,b| a['pos'] <=> b['pos']}
      last  = ne.tokens.max {|a,b| a['pos'] <=> b['pos']}
      # TODO Raise exception if cant find token with named entity's position
      tokens_per_pos[first['pos']][:html] = "<span class=\"ne #{ne.ne_class}\">" + tokens_per_pos[first['pos']][:html]
      tokens_per_pos[last['pos']][:html] << "</span>"
    end

    html = ''
    cur_pos = 0
    tokens_per_pos.each do |token_pos, token|
      html << document.content[cur_pos ... token_pos]
      html << token[:html]
      cur_pos = token_pos + token[:form].size
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
  @document = Document.find_or_initialize_by(:filename => params[:f])
  if @document.new_record?
    @document.content = open(File.join(DOCUMENTS_PATH, params[:f])).read
    @document.save
  end
  if not @document.analyzed?
    @document.analyze!
    @document.save
  end

  @named_entities = @document.named_entities

  erb :analyse
end

post '/analyse' do
  'TODO'
end
