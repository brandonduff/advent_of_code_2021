require 'minitest/autorun'

class Paper
  def initialize(dots)
    @dots = dots
  end

  def dot_count
    @dots.count
  end

  def fold_y(line_y)
    @dots.select { |x, y| y > line_y }.each do |dot|
      dot[1] = line_y - (dot[1] - line_y)
    end
    @dots.uniq!
  end

  def fold_x(line_x)
    @dots.select { |x, y| x > line_x }.each do |dot|
      dot[0] = line_x - (dot[0] - line_x)
    end
    @dots.uniq!
  end

  def fold_instruction(string)
    direction, n = string.split.last.split('=')
    send("fold_#{direction}", n.to_i)
  end

  def to_s
    result = ''
    (0..(@dots.max { |a, b| a[1] <=> b[1] }[1])).each do |x|
      (0..(@dots.max { |a, b| a[0] <=> b[0] }[0])).each do |y|
        result << (@dots.include?([y, x]) ? ' # ' : ' . ')
      end
      result << "\n"
    end
    result
  end
end

class DayThirteenTest < Minitest::Test
  def test_folding_y
    input = [
      [0, 0],
      [0, 2]
    ]

    paper = Paper.new(input)
    paper.fold_y(1)

    assert_equal(1, paper.dot_count)
  end

  def test_folding_x
    input = [
      [0, 0],
      [2, 0]
    ]

    paper = Paper.new(input)
    paper.fold_x(1)

    assert_equal(1, paper.dot_count)
  end

  def test_folding_instructions
    grid_string = <<~INPUT
      6,10
      0,14
      9,10
      0,3
      10,4
      4,11
      6,0
      6,12
      4,1
      0,13
      10,12
      3,4
      3,0
      8,4
      1,10
      2,14
      8,10
      9,0
    INPUT
    grid_input = grid_string.split("\n").map { |line| line.split(',').map(&:to_i) }
    paper = Paper.new(grid_input)
    paper.fold_instruction('fold along y=7')
    paper.fold_instruction('fold along x=5')
    assert_equal(16, paper.dot_count)
  end

  def test_part_one
    input = File.read('day_thirteen_input.txt')
    grid_input, instructions = input.split("\n\n")
    grid_input = grid_input.split("\n").map { |line| line.split(',').map(&:to_i) }
    paper = Paper.new(grid_input)
    first_instruction, *rest = instructions.split("\n")
    paper.fold_instruction(first_instruction)

    assert_equal(837, paper.dot_count)

    rest.each do |instruction|
      paper.fold_instruction(instruction)
    end

    assert_equal(99, paper.dot_count)
    File.write('output.txt', paper.to_s)
  end
end
