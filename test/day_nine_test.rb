require 'minitest/autorun'

Location = Struct.new(:row, :col, :value, :height_map) do
  def >(other)
    value > other.value
  end

  def lowpoint?
    adjacents.all? { |adjacent| adjacent > self }
  end

  def adjacents
    height_map.adjacents(row, col)
  end
end

class HeightMap
  def initialize(input)
    @input = input.split("\n").map(&:chars)
  end

  def risk_level
    lowpoints.sum { |lowpoint| 1 + lowpoint.value }
  end

  def top_three_basin_lengths
    lowpoints.map { |lowpoint| basin_at(lowpoint) }.map(&:length).max(3)
  end

  def lowpoints
    locations.select(&:lowpoint?)
  end

  def at(row, col)
    rows[row][col]
  end

  def rows
    @rows ||= @input.map.with_index { |row, i| row.map.with_index { |value, j| Location.new(i, j, value.to_i, self) } }
  end

  def adjacents(row, col)
    result = []
    result << at(row, col - 1) if col > 0
    result << at(row, col + 1) if col < rows.first.length - 1
    result << at(row - 1, col) if row > 0
    result << at(row + 1, col) if row < rows.length - 1
    result
  end

  def basin_at(location)
    to_visit = [location]
    visited = []

    until to_visit.empty?
      next_location = to_visit.pop
      visited << next_location unless visited.include?(next_location)
      next_location.adjacents.each do |adjacent|
        to_visit << adjacent unless visited.include?(adjacent) || adjacent.value == 9
      end
    end

    visited
  end

  def locations
    rows.flatten
  end
end

class DayNineTest < Minitest::Test
  def test_creating_heightmap
    height_map = HeightMap.new(input)

    assert_equal(9, height_map.at(0, 2).value)
  end

  def test_adjacents
    height_map = HeightMap.new(input)
    assert_equal [1,3], height_map.adjacents(0,0).map(&:value)
    assert_equal [1,1], height_map.adjacents(0,9).map(&:value)
    assert_equal [8, 8], height_map.adjacents(4,0).map(&:value)
    assert_equal [7,9], height_map.adjacents(4,9).map(&:value)
  end

  def test_example
    height_map = HeightMap.new(input)
    assert_equal(15, height_map.risk_level)
  end

  def test_part_one
    height_map = HeightMap.new(file_input)
    assert_equal(528, height_map.risk_level)
  end

  def test_filling_basin
    input = "98765432"
    height_map = HeightMap.new(input)
    assert_equal([2,3,4,5,6,7,8], height_map.basin_at(height_map.at(0, 7)).map(&:value))
  end

  def test_top_three_basin_lengths
    height_map = HeightMap.new(input)
    assert_equal(1134, height_map.top_three_basin_lengths.reduce(:*))
  end

  def test_part_two
    height_map = HeightMap.new(file_input)
    assert_equal(920448, height_map.top_three_basin_lengths.reduce(:*))
  end

  def input
    <<~INPUT
      2199943210
      3987894921
      9856789892
      8767896789
      9899965678
    INPUT
  end

  def file_input
    File.read('day_nine_input.txt')
  end
end
