require 'minitest/autorun'

class DayThree
  attr_reader :input

  def initialize(input)
    @input = input
  end

  def part_one
    gamma = cols.map { |col| col.count("0") > col.count("1") ? "0" : "1" }.join.to_i(2)
    epsilon = cols.map { |col| col.count("0") < col.count("1") ? "0" : "1" }.join.to_i(2)
    gamma * epsilon
  end

  def part_two
    OxygenGeneratorRating.new(binaries).to_i * Co2ScrubberRating.new(binaries).to_i
  end

  def binaries
    Binaries.new(input.split("\n"))
  end

  def cols
    binaries.cols
  end

  class Binaries
    include Enumerable

    attr_reader :bit_criteria

    def initialize(input)
      @input = input
      @bit_criteria = 0
    end

    def to_binaries
      self
    end

    def each(*args, &block)
      @input.each(*args, &block)
    end

    def cols
      map(&:chars).transpose
    end

    def iterate(instrument_config)
      generator_rating = generator_rating(instrument_config)
      @input = select { |binary| binary[bit_criteria] == generator_rating }
      @bit_criteria += 1
      self
    end

    def reduced?
      @input.length == 1
    end

    def generator_rating(instrument_config)
      instrument_config.rating_for(cols[bit_criteria])
    end
  end

  InstrumentConfig = Struct.new(:tie_winning_number, :tie_losing_number, :comparison) do
    def rating_for(binary)
      binary.count(tie_losing_number).send(comparison, binary.count(tie_winning_number)) ? tie_losing_number : tie_winning_number
    end
  end

  class OxygenGeneratorRating
    attr_reader :binaries

    def initialize(binaries)
      @binaries = binaries.to_binaries
    end

    def to_i
      reduction.first.to_i(2)
    end

    def reduction
      binaries.iterate(InstrumentConfig.new(tie_winning_number, tie_losing_number, comparison)) until binaries.reduced?
      binaries
    end

    def tie_losing_number
      "0"
    end

    def tie_winning_number
      tie_losing_number == "0" ? "1" : "0"
    end

    def comparison
      :>
    end
  end

  class Co2ScrubberRating < OxygenGeneratorRating
    def tie_losing_number
      "1"
    end

    def comparison
      :<
    end
  end
end

class Array
  def to_binaries
    DayThree::Binaries.new(self)
  end
end

class DayThreeTest < Minitest::Test
  def test_part_one_simple
    input = <<~INPUT
      00100
      11110
      10110
      10111
      10101
      01111
      00111
      11100
      10000
      11001
      00010
      01010
    INPUT
    assert_equal 198, DayThree.new(input).part_one
  end

  def test_part_one_with_puzzle_input
    assert_equal 845186, DayThree.new(file_input).part_one
  end

  def test_oxygen_generator_rating_with_single_value
    assert_equal 0b00100, DayThree::OxygenGeneratorRating.new(["00100"]).to_i
  end

  def test_oxygen_generator_rating_two_values
    binaries = ["00001", "11111"]
    assert_equal 0b11111, DayThree::OxygenGeneratorRating.new(binaries).to_i
  end

  def test_oxygen_generator_rating_many_values
    binaries = ["00001", "10110", "11111"]
    assert_equal 0b11111, DayThree::OxygenGeneratorRating.new(binaries).to_i
  end

  def test_co2_scrubber_rating
    binaries = ["00011", "11110", "11111"]
    assert_equal 0b00011, DayThree::Co2ScrubberRating.new(binaries).to_i
  end

  def test_life_support_rating
    input = <<~BIN
      00100
      11110
      10110
      10111
      10101
      01111
      00111
      11100
      10000
      11001
      00010
      01010
    BIN
    assert_equal 230, DayThree.new(input).part_two
  end

  def test_part_two_with_puzzle_input
    assert_equal 4636702, DayThree.new(file_input).part_two
  end

  def file_input
    File.read("day_three_input.txt")
  end
end
