require 'freeling/analyzer'
require 'token'
require 'named_entity'

class Document
  include Mongoid::Document

  field :text, :type => String

  has_many    :tokens, :dependent => :delete
  embeds_many :named_entities


  def analyze
    self.tokens.destroy_all
    self.tokens.clear
    self.tokens = []
    tokens_from_analyzer.each do |token|
      self.tokens << token
      token.save
    end

    self.named_entities.destroy_all
    self.named_entities.clear
    self.named_entities = []
    named_entities_from_analyzer(self.tokens).each do |named_entity|
      self.named_entities << named_entity
    end
  end


private
  # Return an enumerator of tokens
  #
  # All tokens have a reference to the original text and its position in the
  # string for locating it easily.
  #
  def tokens_from_analyzer
    Enumerator.new do |yielder|
      pos = 0
      analyzer = FreeLing::Analyzer.new(text, :output_format => :token)
      analyzer.tokens.each do |token|
        token_pos = text.index(token[:form], pos)
        yielder << Token.new(token.merge(:pos => token_pos))
        pos = token_pos + token[:form].size
      end
    end
  end

  # Return an enumerator of named entities
  #
  # Each named entity will reference the original token, so this method accepts
  # an array of known tokens as a parameter for this purpose.
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
  def named_entities_from_analyzer(tokens=nil)
    Enumerator.new do |yielder|
      # FIXME use the internal iterator instead of a counter (cur_st)
      st = (tokens || self.tokens_from_analyzer).to_a
      cur_st = 0
      analyzer = FreeLing::Analyzer.new(text, :output_format => :tagged)
      analyzer.tokens.each do |token|

        # exact match
        if token[:form] == st[cur_st].form
          if Token::NE_CLASSES_PER_TAG[token[:tag]]
            yielder << NamedEntity.new(token.merge({
              :ne_class => st[cur_st].ne_class,
              :pos => st[cur_st].pos,
              :tokens => [st[cur_st]],
            }))
          end
          cur_st += 1

        # multiword
        # e.g. John Doe ==> tokens        = ["John", "Doe"]
        #                   tagged_tokens = ["John_Doe"]
        elsif token[:form] =~ /^#{st[cur_st].form}_/
          token_pos = st[cur_st].pos
          tokens = []
          m_word = token[:form].dup
          while not m_word.empty? and m_word.start_with?(st[cur_st].form)
            tokens << st[cur_st]
            m_word = m_word.slice(st[cur_st].form.size + 1 .. -1).to_s
            cur_st += 1
          end
          if Token::NE_CLASSES_PER_TAG[token[:tag]]
            yielder << NamedEntity.new(token.merge({
              :ne_class => Token::NE_CLASSES_PER_TAG[token[:tag]],
              :pos => token_pos,
              :tokens => tokens,
            }))
          end

        else
          raise "Simple tokens and tagged tokens do not match " \
                "(#{st[cur_st].form} != #{token[:form]}). Maybe a contraction?"
        end
      end
    end
  end

end
