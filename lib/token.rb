module FreeLing

  TAGS_PER_CLASS = {
    organizations: 'NP00O00',
    others: 'NP00V00',
    people: 'NP00SP0',
    places: 'NP00G00',
    unknown: 'NP00000',
    date: 'W',
  }

  CLASSES_PER_TAG = TAGS_PER_CLASS.invert


  class Token
    attr_reader :form
    attr_accessor :text, :offset, :words, :metadata

    def initialize(form, opts={})
      @form = form.to_s
      @text = opts[:text]
      @offset = opts[:offset] && opts[:offset].to_i
      @metadata = opts[:metadata]
      @words = opts[:words]
    end

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

    def named_entity?
      if @metadata
        @metadata[:tag].start_with?('NP')
      end
    end

    def date?
      if @metadata
        @metadata[:tag] == TAGS_PER_CLASS[:date]
      end
    end

    def class
      if @metadata
        CLASSES_PER_TAG[@metadata[:tag]]
      end
    end

    def multiword?
      @words and @words.size > 1
    end
  end

end
