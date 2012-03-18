class NamedEntity
  include Mongoid::Document

  field :text
  field :class
  field :pos

  embedded_in :document
  has_many :tokens
end
