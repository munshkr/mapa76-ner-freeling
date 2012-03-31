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
    self.named_entities = []
    named_entities_from_analyzer.each do |named_entity|
      self.named_entities.push(named_entity)
    end
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
      analyzer = FreeLing::Analyzer.new(content, :output_format => :token, :memoize => false)
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
      st = self.tokens
      cur_st = st.next
      analyzer = FreeLing::Analyzer.new(content, :output_format => :tagged, :memoize => false)
      analyzer.tokens.each do |token|

        # exact match
        if token[:form] == cur_st[:form]
          if NamedEntity::CLASSES_PER_TAG[token[:tag]]
            yielder << NamedEntity.new(token.merge({
              :pos => cur_st[:pos],
              :tokens => [{ :pos => cur_st[:pos], :form => cur_st[:form] }],
            }))
          end
          cur_st = st.next

        # multiword
        # e.g. John Doe ==> tokens        = ["John", "Doe"]
        #                   tagged_tokens = ["John_Doe"]
        elsif token[:form] =~ /^#{cur_st[:form]}_/
          token_pos = cur_st[:pos]
          tokens = []
          m_word = token[:form].dup
          while not m_word.empty? and m_word.start_with?(cur_st[:form])
            tokens << { :pos => cur_st[:pos], :form => cur_st[:form] }
            m_word = m_word.slice(cur_st[:form].size + 1 .. -1).to_s
            cur_st = st.next
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
                "(#{cur_st[:form]} != #{token[:form]}). Maybe a contraction?"
        end
      end
    end
  end

end
