require 'document'
require 'token'

class NamedEntity
  include Mongoid::Document

  field :ne_class, :type => Symbol
  field :form,     :type => String
  field :lemma,    :type => String
  field :tag,      :type => String
  field :prob,     :type => Float
  field :pos,      :type => Integer

  embedded_in :document
  has_many    :tokens
end
