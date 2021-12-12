require 'minitest/autorun'

class Grid
  include Enumerable

  def initialize(grid_array, &block)
    @grid_array = cellify(grid_array, &block)
  end

  def neighbors(row, col)
    result = []
    result << @grid_array[row - 1][col - 1] if row > 0 && col > 0
    result << @grid_array[row - 1][col] if row > 0
    result << @grid_array[row - 1][col + 1] if row > 0 && col < width - 1
    result << @grid_array[row][col - 1] if col > 0
    result << @grid_array[row][col + 1] if col < width - 1
    result << @grid_array[row + 1][col - 1] if col > 0 && row < height - 1
    result << @grid_array[row + 1][col] if row < height - 1
    result << @grid_array[row + 1][col + 1] if row < height - 1 && col < width - 1
    result
  end

  def each(*args, &block)
    @grid_array.flatten.map(&:value).each(*args, &block)
  end

  def at(row, col)
    @grid_array[row][col].value
  end

  def width
    @grid_array.first.length
  end

  def height
    @grid_array.length
  end

  def cellify(grid_array, &block)
    grid_array.map.with_index do |row, i|
      row.map.with_index do |value, j|
        Cell.new(i, j, self).tap do |cell|
          block.call(value).cell = cell if block_given?
        end
      end
    end
  end
end

class Cell
  attr_reader :row, :col
  attr_accessor :value

  def initialize(row, col, grid)
    @row = row
    @col = col
    @grid = grid
  end

  def neighbors
    @grid.neighbors(@row, @col)
  end
end

module Cellable
  attr_reader :cell

  def cell=(cell)
    @cell = cell
    @cell.value = self
  end

  def neighbors
    cell.neighbors.map(&:value)
  end
end

class Octopus
  include Cellable
  attr_accessor :energy

  def initialize(energy)
    @energy = energy
  end

  def increment
    @energy += 1
    flash if energy > 9 && !flashed?
  end

  def flash
    @flashed = true
    neighbors.each(&:increment)
  end

  def flashed?
    @flashed
  end

  def reset
    @energy = 0 if @energy > 9
    @flashed = false
  end
end

class Simulator
  attr_reader :grid

  def initialize(grid)
    @grid = grid
    @flashed_count = 0
  end

  def step
    @last_flashed_count = 0

    grid.each do |octopus|
      octopus.increment
    end

    grid.each do |octopus|
      if octopus.flashed?
        @flashed_count += 1
        @last_flashed_count += 1
      end

      octopus.reset
    end
  end

  def flashed_count
    @flashed_count
  end

  def all_flashed?
    @last_flashed_count == @grid.entries.size
  end
end

class DayElevenTest < Minitest::Test
  attr_reader :octopus, :grid, :neighboring_octopus

  def setup
    @grid = Grid.new([[0, 2]]) { |value| Octopus.new(value) }
    @octopus = @grid.at(0, 0)
    @neighboring_octopus = @grid.at(0, 1)
  end

  def test_cell_neighbors
    cell = Cell.new(1, 1, Grid.new([[0,1,2,3],[4,5,6,7],[8,9,10,11],[12,13,14,15]]))
    neighbors = cell.neighbors

    assert_equal(0, neighbors.first.row)
    assert_equal(0, neighbors.first.col)

    assert_equal(0, neighbors[1].row)
    assert_equal(1, neighbors[1].col)

    assert_equal(0, neighbors[2].row)
    assert_equal(2, neighbors[2].col)

    assert_equal(1, neighbors[3].row)
    assert_equal(0, neighbors[3].col)

    assert_equal(1, neighbors[4].row)
    assert_equal(2, neighbors[4].col)

    assert_equal(2, neighbors[5].row)
    assert_equal(0, neighbors[5].col)

    assert_equal(2, neighbors[6].row)
    assert_equal(1, neighbors[6].col)

    assert_equal(2, neighbors[7].row)
    assert_equal(2, neighbors[7].col)
  end

  def test_cellable_octopus
    grid = Grid.new([[0, 2]]) { |value| Octopus.new(value) }
    octopus = grid.at(0, 0)
    neighboring_octopus = grid.at(0, 1)

    assert_equal(neighboring_octopus, octopus.neighbors.first)
  end

  def test_flashing
    octopus.energy = 9
    octopus.increment

    assert_equal(10, octopus.energy)
    assert_equal(3, neighboring_octopus.energy)
  end

  def test_only_flashes_once
    octopus.energy = 9
    octopus.increment
    octopus.increment

    assert_equal(11, octopus.energy)
    assert_equal(3, neighboring_octopus.energy)
  end

  def test_reseting_flash
    octopus.energy = 9
    octopus.increment
    octopus.increment
    octopus.reset

    assert_equal(0, octopus.energy)
    assert_equal(3, neighboring_octopus.energy)
  end

  def test_stepping
    grid_string = <<~INPUT
      11111
      19991
      19191
      19991
      11111
    INPUT
    grid_array = grid_string.split("\n").map do |line|
      line.split('').map(&:to_i)
    end

    grid = Grid.new(grid_array) { |value| Octopus.new(value) }
    simulator = Simulator.new(grid)
    simulator.step

    # 34543
    # 40004
    # 50005
    # 40004
    # 34543
    assert_equal(0, grid.at(1,1).energy)
    assert_equal(3, grid.at(0,0).energy)
    assert_equal(9, simulator.flashed_count)
  end

  def test_part_one
    simulator = Simulator.new(file_grid)
    100.times { simulator.step }

    assert_equal(1688, simulator.flashed_count)
  end

  def test_all_flashed
    grid_array = [[8, 8], [8, 8]]
    grid = Grid.new(grid_array) { |value| Octopus.new(value) }
    simulator = Simulator.new(grid)

    simulator.step
    refute simulator.all_flashed?

    simulator.step
    assert simulator.all_flashed?
  end

  def test_part_two
    simulator = Simulator.new(file_grid)

    current_step = 0
    until simulator.all_flashed?
      current_step += 1
      simulator.step
    end

    assert_equal(403, current_step)
  end

  def file_grid
    grid_array = File.read('day_eleven_input.txt').split("\n").map do |line|
      line.split('').map(&:to_i)
    end

    Grid.new(grid_array) { |value| Octopus.new(value) }
  end
end
