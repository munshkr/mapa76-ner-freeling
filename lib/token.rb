require 'document'

class Token
  include Mongoid::Document

  field :form,  :type => String
  field :lemma, :type => String
  field :tag,   :type => String
  field :prob,  :type => Float
  field :pos,   :type => Integer

  belongs_to :document
  belongs_to :named_entity


  NE_CLASSES_PER_TAG = {
    'NP00O00' => :organizations,
    'NP00V00' => :others,
    'NP00SP0' => :people,
    'NP00G00' => :places,
    'NP00000' => :unknown,
    'W'       => :dates,
  }


  def named_entity?
    NE_CLASSES_PER_TAG.has_key?(tag) if tag
  end

  def ne_class
    NE_CLASSES_PER_TAG[tag] if tag
  end

=begin
  def to_s
    str = "\"#{@form}\""
    str << " (#{@metadata.values.join(', ')})" if @metadata
    str
  end

  def orig_form
    if @text and @offset
      @text[@offset .. @offset + @form.size - 1]
    end
  end
=end
end
