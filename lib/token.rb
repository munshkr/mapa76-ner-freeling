require 'document'
require 'named_entity'

class Token
  include Mongoid::Document

  field :form, :type => String
  field :pos,  :type => Integer

  belongs_to :document
  belongs_to :named_entity


  def self.named_entity_class(token)
    NamedEntity::CLASSES_PER_TAG[token[:tag]] if token[:tag]
  end

  def self.named_entity?(token)
    !!named_entity_class(token)
  end

  def named_entity_class
    self.class.named_entity_class(self)
  end

  def named_entity?
    self.class.named_entity?(self)
  end

  def original_text
    document.content[pos ... pos + form.size]
  end
end
