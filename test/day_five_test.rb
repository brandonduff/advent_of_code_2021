require 'minitest/autorun'

Point = Struct.new(:x, :y) do
  def self.from_string(string)
    x, y = string.split(',').map(&:to_i)
    new(x, y)
  end
end

class Line
  def self.from_string(arg)
    points = arg.split(' -> ').map { |string| Point.from_string(string) }
    new(points[0], points[1])
  end

  attr_reader :start_point, :end_point

  def initialize(start_point, end_point)
    @start_point = start_point
    @end_point = end_point
    normalize_line
  end

  def each
    if vertical?
      if start_point.y > end_point.y
        temp = @start_point
        @start_point = @end_point
        @end_point = temp
      end
      (start_point.y..end_point.y).each do |next_y|
        yield Point.new(start_point.x, next_y)
      end
    else
      (end_point.x - start_point.x + 1).times do |i|
        yield Point.new(start_point.x + i, start_point.y + (i * slope))
      end
    end
  end

  def slope
    if end_point.x - start_point.x == 0
      return Float::INFINITY
    else
      (end_point.y - start_point.y) / (end_point.x - start_point.x)
    end
  end

  def vertical?
    slope == Float::INFINITY
  end

  def diagonal?
    !slope.zero? && !slope.infinite?
  end

  private

  def normalize_line
    if end_point.x < start_point.x
      temp = @start_point
      @start_point = @end_point
      @end_point = temp
    end
  end
end

class Overlaps
  def initialize
    @points_at = Hash.new(0)
  end

  def traverse(line)
    line.each { |point| @points_at[point] += 1 }
  end

  def [](point)
    @points_at[point]
  end

  def count
    @points_at.values.count { |count| count > 1 }
  end
end

class DayFiveTest < Minitest::Test
  def test_line_creation
    line = Line.from_string('348,742 -> 620,742')
    assert_equal 348, line.start_point.x
    assert_equal 742, line.start_point.y
    assert_equal 620, line.end_point.x
    assert_equal 742, line.end_point.y
  end

  def test_detecting_diagonal
    vertical_line = Line.new(Point.new(0,0), Point.new(0,5))
    horizontal_line = Line.new(Point.new(0,0), Point.new(5,0))
    diagonal_line = Line.new(Point.new(0,0), Point.new(5,5))

    refute vertical_line.diagonal?
    refute horizontal_line.diagonal?
    assert diagonal_line.diagonal?
  end

  def test_detecting_overlaps
    overlaps = Overlaps.new
    first_line = Line.new(Point.new(2,0), Point.new(3,0))
    second_line = Line.new(Point.new(3,0), Point.new(4,0))
    third_line = Line.new(Point.new(3,0), Point.new(3,1))

    overlaps.traverse(first_line)
    overlaps.traverse(second_line)
    overlaps.traverse(third_line)

    assert_equal 1, overlaps[Point.new(2,0)]
    assert_equal 3, overlaps[Point.new(3,0)]
    assert_equal 1, overlaps[Point.new(4,0)]
  end

  def test_initialized_backwards
    line = Line.from_string('2,0 -> 0,0')
    assert_equal 0, line.start_point.x
  end

  def test_example
    example = <<~INPUT
      0,9 -> 5,9
      8,0 -> 0,8
      9,4 -> 3,4
      2,2 -> 2,1
      7,0 -> 7,4
      6,4 -> 2,0
      0,9 -> 2,9
      3,4 -> 1,4
      0,0 -> 8,8
      5,5 -> 8,2
    INPUT
    lines = example.split("\n").map { |string| Line.from_string(string) }
    lines = lines.reject(&:diagonal?)
    overlaps = Overlaps.new
    lines.each { |line| overlaps.traverse(line) }
    assert_equal 5, overlaps.count
  end

  def test_part_one
    input = File.read("day_five_input.txt")
    lines = input.split("\n").map { |string| Line.from_string(string) }
    lines = lines.reject(&:diagonal?)
    overlaps = Overlaps.new
    lines.each { |line| overlaps.traverse(line) }
    assert_equal 4826, overlaps.count
  end

  def test_slope
    horizontal_line = Line.from_string('0,0 -> 2,0')
    vertical_line = Line.from_string('0,0 -> 0,2')
    assert_equal 0, horizontal_line.slope
    assert_equal Float::INFINITY, vertical_line.slope
  end

  def test_normalizing_line
    backwards_horizontal = Line.new(Point.new(2,0), Point.new(0,0))
    backwards_vertical = Line.new(Point.new(0,4), Point.new(0,0))
    forwards_diagonal = Line.new(Point.new(0,0), Point.new(2,2))
    backwards_diagonal = Line.new(Point.new(2,2), Point.new(0,0))
    assert_equal Point.new(0,0), backwards_horizontal.start_point
    assert_equal Point.new(0,4), backwards_vertical.start_point
    assert_equal Point.new(0,0), forwards_diagonal.start_point
    assert_equal Point.new(0,0), backwards_diagonal.start_point
  end

  def test_counting_diagonals
    line = Line.new(Point.new(0,0), Point.new(2,2))
    overlaps = Overlaps.new
    overlaps.traverse(line)
    assert_equal 1, overlaps[Point.new(0,0)]
    assert_equal 1, overlaps[Point.new(1,1)]
    assert_equal 1, overlaps[Point.new(2,2)]
  end 

  def test_counting_increasing_x_diagonal
    # /
    line = Line.from_string('0,2 -> 2,0')
    overlaps = Overlaps.new
    overlaps.traverse(line)
    assert_equal 1, overlaps[Point.new(0,2)]
    assert_equal 1, overlaps[Point.new(1,1)]
    assert_equal 1, overlaps[Point.new(2,0)]
  end

  def test_decreasing_y_diagonal
    line = Line.from_string('9,7 -> 7,9')
    overlaps = Overlaps.new
    overlaps.traverse(line)
    assert_equal Point.new(7,9), line.start_point
    assert_equal 1, overlaps[Point.new(9,7)]
    assert_equal 1, overlaps[Point.new(8,8)]
    assert_equal 1, overlaps[Point.new(7,9)]
  end

  def test_part_two
    input = File.read("day_five_input.txt")
    lines = input.split("\n").map { |string| Line.from_string(string) }
    overlaps = Overlaps.new
    lines.each { |line| overlaps.traverse(line) }
    assert_equal 16793, overlaps.count
  end
end
