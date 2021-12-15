require 'minitest/autorun'

class PolymerTemplate
  attr_reader :pairs, :elements

  def initialize(string)
    @string = string
    @rules = []
    @pairs = Hash.new(0)
    string.chars.each_cons(2).tally.each do |k, v|
      @pairs[k] = v
    end
    @elements = Hash.new(0)
    string.chars.each do |c|
      @elements[c] += 1
    end
  end

  def add_rule(rule)
    @rules << rule
  end

  def step
    result = Hash.new(0)
    @pairs.each do |pair, tally|
      if (rule = @rules.detect { |rule| rule.pair == pair })
        result[[pair.first, rule.insertion_character]] += tally
        result[[rule.insertion_character, pair.last]] += tally
        @elements[rule.insertion_character] += tally
        result[pair] -= tally
      end
    end
    result.each do |pair, tally|
      @pairs[pair] += tally
    end
  end
end

class PairInsertionRule
  attr_reader :pair, :insertion_character

  def initialize(pair, insertion_character)
    @pair = pair.chars
    @insertion_character = insertion_character
  end
end

class DayFourteenTest < Minitest::Test
  def test_simple_insertion
    template = PolymerTemplate.new('AA')
    rule = PairInsertionRule.new('AA', 'B')
    template.add_rule(rule)
    template.step
    assert_equal(1, template.pairs.values.max - template.pairs.values.min)
  end

  def test_part_one
    input = File.read('day_fourteen_input.txt')
    template, rules = input.split("\n\n")
    template = PolymerTemplate.new(template)
    rules = rules.split("\n").map do |rule|
      pair, insertion_character = rule.split(' -> ')
      PairInsertionRule.new(pair, insertion_character)
    end

    rules.each { |rule| template.add_rule(rule) }
    10.times { template.step }
    result = template.elements.values.reject(&:zero?)
    assert_equal(2967, result.max - result.min)

    30.times { template.step }
    result = template.elements.values.reject(&:zero?)
    assert_equal(3692219987038, result.max - result.min)
  end
end
