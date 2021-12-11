require 'minitest/autorun'

class String
  def opposite
    case self
    when '['
      ']'
    when '('
      ')'
    when '<'
      '>'
    when '{'
      '}'
    else
      raise "not a chunk opening: #{self}"
    end
  end

  def chunk_opening?
    ['[', '(', '<', '{'].include?(self)
  end

  def corrupted_char
    stack = []
    chars.each do |c|
      if c.chunk_opening?
        stack << c.opposite
      else
        matching = stack.pop
        if matching != c
          return c
        end
      end
    end
    nil
  end

  def syntax_error_score
    corrupted_char.score
  end

  def score
    case self
    when '}'
      1197
    when ')'
      3
    when ']'
      57
    when '>'
      25137
    else
      raise "not a chunk closing: #{self}"
    end
  end

  def completion_string
    stack = []
    chars.each do |c|
      if c.chunk_opening?
        stack << c.opposite
      else
        matching = stack.pop
        if matching != c
          return c
        end
      end
    end
    stack.reverse.join
  end

  def autocomplete_score
    chars.reduce(0) { |result, c| result * 5 + c.autocomplete_value }
  end

  def autocomplete_value
    case self
    when ']'
      2
    when ')'
      1
    when '}'
      3
    when '>'
      4
    else
      raise "not a chunk closing: #{self}"
    end
  end
end

class DayTenTest < Minitest::Test
  def test_opposites
    assert_equal(']', '['.opposite)
    assert_equal(')', '('.opposite)
    assert_equal('>', '<'.opposite)
    assert_equal('}', '{'.opposite)
  end

  def test_corrupted_char
    assert_nil('()'.corrupted_char)
    assert_equal(']', '(]'.corrupted_char)
    assert_nil('(())'.corrupted_char)
    assert_nil('()()'.corrupted_char)
    assert_equal('}', '(()}'.corrupted_char)
  end

  def test_syntax_error_score
    assert_equal(1197, '{([(<{}[<>[]}>{[]{[(<()>'.syntax_error_score)
    assert_equal(3, '[[<[([]))<([[{}[[()]]]'.syntax_error_score)
    assert_equal(57, '[{[{({}]{}}([{[{{{}}([]'.syntax_error_score)
    assert_equal(25137, '<{([([[(<>()){}]>(<<{{'.syntax_error_score)
  end

  def test_part_one
    result = file_input.split("\n").sum do |line|
      if line.corrupted_char
        line.syntax_error_score
      else
        0
      end
    end
    assert_equal(392367, result)
  end

  def test_completion_string
    assert_equal(')', '('.completion_string)
    assert_equal('))', '(('.completion_string)
    assert_equal('}', '()}'.completion_string)
    assert_equal('})', '(){}({'.completion_string)
    assert_equal('', '()'.completion_string)
  end

  def test_autocomplete_score
    assert_equal(294, '])}>'.autocomplete_score)
    assert_equal(0, ''.autocomplete_score)
  end

  def test_part_two
    autocomplete_scores = file_input.split("\n").reject(&:corrupted_char).map(&:completion_string).map(&:autocomplete_score)
    assert_equal(2192104158, autocomplete_scores.sort[autocomplete_scores.length / 2])
  end

  def file_input
    File.read('day_ten_input.txt')
  end
end
