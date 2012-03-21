require 'freeling/analyzer'
require 'named_entity'

class Document
  include Mongoid::Document

  field :content,       :type => String
  field :filename,      :type => String
  field :last_analysis, :type => Time

  embeds_many :named_entities


  def analyzed?
    !!self.last_analysis
  end

  def analyze
    analyze! if not analyzed?
  end

  def analyze!
    self.named_entities = named_entities_from_analyzer.to_a
    self.last_analysis = Time.now
  end

  # Return an enumerator of tokens
  #
  # All tokens have a reference to the original text and its position in the
  # string for locating it easily.
  #
  def tokens
    Enumerator.new do |yielder|
      pos = 0
      analyzer = FreeLing::Analyzer.new(content, :output_format => :token)
      analyzer.tokens.each do |token|
        token_pos = content.index(token[:form], pos)
        yielder << token.merge(:pos => token_pos)
        pos = token_pos + token[:form].size
      end
    end
  end


private
  # Return an enumerator of named entities
  #
  # NOTE This function works correctly *only if* the following FreeLing
  # config options are reset:
  #
  #   RetokContractions=no
  #   TaggerRetokenize=no
  #
  # When any of these are set, Dictionary or Tagger modules can retokenize
  # contracted words (e.g. "he's" => "he is"), changing the original text.
  # An exception is raised if this happens.
  #
  def named_entities_from_analyzer
    Enumerator.new do |yielder|
      # FIXME use the internal iterator instead of a counter (cur_st)
      st = self.tokens.to_a
      cur_st = 0
      analyzer = FreeLing::Analyzer.new(content, :output_format => :tagged)
      analyzer.tokens.each do |token|

        # exact match
        if token[:form] == st[cur_st][:form]
          if NamedEntity::CLASSES_PER_TAG[token[:tag]]
            yielder << NamedEntity.new(token.merge({
              :pos => st[cur_st][:pos],
              :tokens => [{ :pos => st[cur_st][:pos], :form => st[cur_st][:form] }],
            }))
          end
          cur_st += 1

        # multiword
        # e.g. John Doe ==> tokens        = ["John", "Doe"]
        #                   tagged_tokens = ["John_Doe"]
        elsif token[:form] =~ /^#{st[cur_st][:form]}_/
          token_pos = st[cur_st][:pos]
          tokens = []
          m_word = token[:form].dup
          while not m_word.empty? and m_word.start_with?(st[cur_st][:form])
            tokens << { :pos => st[cur_st][:pos], :form => st[cur_st][:form] }
            m_word = m_word.slice(st[cur_st][:form].size + 1 .. -1).to_s
            cur_st += 1
          end
          if ne_class = NamedEntity::CLASSES_PER_TAG[token[:tag]]
            yielder << NamedEntity.new(token.merge({
              :ne_class => ne_class,
              :pos => token_pos,
              :tokens => tokens,
            }))
          end

        else
          raise "Simple tokens and tagged tokens do not match " \
                "(#{st[cur_st][:form]} != #{token[:form]}). Maybe a contraction?"
        end
      end
    end
  end

end
