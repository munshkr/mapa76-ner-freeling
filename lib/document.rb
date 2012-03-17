# encoding: utf-8
require 'freeling/analyzer'


class Document
  attr_reader :text

  def initialize(text)
    @text = text
    @analyzer ||= {}
  end

  # Return an array of tokens.
  #
  # All tokens have a reference to the original text and its offset in the
  # string for locating it easily.
  #
  def tokens
    Enumerator.new do |yielder|
      cur_off = 0
      @analyzer[:token] ||= FreeLing::Analyzer.new(@text, :output_format => :token)
      @analyzer[:token].tokens.each do |token|
        token.text = @text
        # FIXME replace String#index for something supported by IO objects
        token.offset = @text.index(token.form, cur_off)
        cur_off = token.offset + token.form.size
        yielder << token
      end
    end
  end

  # Return an array of tagged tokens.
  #
  # All tokens have a reference to the original text and its offset in the
  # string for locating it easily.
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
  def tagged_tokens
    Enumerator.new do |yielder|
      # FIXME do not convert to array, use the internal iterator
      st = self.tokens.to_a
      cur_st = 0
      @analyzer[:tagged] ||= FreeLing::Analyzer.new(@text, :output_format => :tagged)
      @analyzer[:tagged].tokens.each do |token|
        token.text = @text

        # exact match
        if st[cur_st].form == token.form
          token.offset = st[cur_st].offset
          cur_st += 1
          yielder << token
        # multiword
        # e.g. John Doe ==> tokens        = ["John", "Doe"]
        #                   tagged_tokens = ["John_Doe"]
        elsif token.form =~ /^#{st[cur_st].form}_/
          token.offset = st[cur_st].offset
          token.words = {}
          m_word = token.form.dup
          while not m_word.empty? and m_word.start_with?(st[cur_st].form)
            token.words[st[cur_st].offset] = st[cur_st].form
            m_word = m_word.slice(st[cur_st].form.size + 1 .. -1).to_s
            cur_st += 1
          end
          yielder << token
        else
          raise "Simple tokens and tagged tokens do not match " \
                "(#{st[cur_st]} != #{token}). Maybe a contraction?"
        end
      end
    end
  end
end
