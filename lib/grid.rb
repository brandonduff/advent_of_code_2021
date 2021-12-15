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
