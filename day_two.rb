require 'minitest/autorun'

class DayTwo
  def self.part_one(input)
    new(input).part_one
  end

  def self.part_two(input)
    new(input).part_two
  end

  attr_reader :input, :horizontal_position, :depth, :aim

  def initialize(input)
    @horizontal_position = 0
    @depth = 0
    @aim = 0
    @input = input
  end

  def part_one
    run
    horizontal_position * aim
  end

  def part_two
    run
    horizontal_position * depth
  end

  def run
    lines.each do |instruction, magnitude|
      case instruction
      when 'forward'
        @horizontal_position += magnitude
        @depth += aim * magnitude
      when 'down'
        @aim += magnitude
      when 'up'
        @aim -= magnitude
      end
    end
  end

  def lines
    input.split("\n").map do |line|
      instruction, magnitude = line.split(" ")
      [instruction, magnitude.to_i]
    end
  end
end

class DayTwoTest < Minitest::Test
  attr_reader :input

  def setup
    @input = <<~INPUT
      forward 5
      down 5
      forward 8
      up 3
      down 8
      forward 2
    INPUT
  end

  def test_simple_solve
    assert_equal 150, DayTwo.part_one(input)
  end

  def test_part_one
    input = File.read("day_two_input.txt")

    assert_equal 2019945, DayTwo.part_one(input)
  end

  def test_simple_part_two
    assert_equal 900, DayTwo.part_two(input)
  end

  def test_part_two
    input = File.read("day_two_input.txt")

    assert_equal 1599311480, DayTwo.part_two(input)
  end
end
