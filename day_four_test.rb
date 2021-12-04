require 'minitest/autorun'

class Integer
  def to_bingo_number
    DayThree::BingoNumber.new(self)
  end
end

class DayThree
  class BingoBoard
    attr_reader :last_marked

    def initialize(elements)
      @elements = bingofy_elements(elements)
    end

    def bingo?
      bingo_for?(rows) || bingo_for?(columns)
    end

    def score
      squares.reject(&:marked?).sum * last_marked
    end

    def rows
      @elements
    end

    def columns
      rows.transpose
    end


    def get_diagonal(rows)
      rows.map.with_index do |row, i|
        row[i]
      end
    end

    def mark(number)
      @last_marked = number
      squares.select { |square| square == number }.each(&:mark)
    end

    def squares
      @elements.flatten
    end

    private

    def bingo_for?(rows)
      rows.any? { |squares| squares.all?(&:marked?) }
    end

    def bingofy_elements(elements)
      elements.map do |row|
        row.map { |number| BingoNumber.new(number) }
      end
    end
  end

  class BingoNumber
    def initialize(value)
      @value = value
      @marked = false
    end

    def to_bingo_number
      self
    end

    def coerce(other)
      [BingoNumber.new(other), self]
    end

    def ==(other)
      value == other.to_bingo_number.value
    end

    def +(other)
      self.class.new(value + other.to_bingo_number.value)
    end

    def *(other)
      self.class.new(value * other.to_bingo_number.value)
    end

    def marked?
      @marked
    end

    def mark
      @marked = true
    end

    protected

    attr_reader :value
  end

  class BingoGame
    def initialize(drawn_numbers, boards)
      @drawn_numbers = drawn_numbers
      @boards = boards
    end

    def winning_score
      @drawn_numbers.each do |drawn|
        @boards.each do |board|
          board.mark(drawn)
          return board.score if board.bingo?
        end
      end
    end

    def last_winning_score
      winning_boards = []
      drawings = @drawn_numbers.each
      until winning_boards.length == @boards.length
        number = drawings.next
        @boards.each do |board|
          board.mark(number)
          winning_boards << board if board.bingo? && !winning_boards.include?(board)
        end
      end
      winning_boards.last.score
    end
  end

  class DayFourTest < Minitest::Test
    attr_reader :elements

    def setup
      @elements = [
        [14, 21, 17, 24, 4],
        [10, 16, 15, 9, 19],
        [18, 8, 23, 26, 20],
        [22, 11, 13, 6, 5],
        [2, 0, 12, 3, 7]
      ]
    end

    def test_bingo_board_rows
      assert_equal [14, 21, 17, 24, 4], board.rows.first
    end

    def test_bingo_board_columns
      assert_equal [14, 10, 18, 22, 2], board.columns.first
    end

    def test_marking_bingo_square
      board.mark(14)
      assert board.rows.first.first.marked?
      refute board.rows.first.last.marked?
    end

    def test_detecting_bingo_row
      board.rows.first.each(&:mark)
      assert board.bingo?
    end

    def test_detecting_bingo_column
      board.columns.first.each(&:mark)
      assert board.bingo?
    end

    def test_scoring
      board.mark(7)
      board.mark(4)
      board.mark(9)
      board.mark(5)
      board.mark(11)
      board.mark(17)
      board.mark(23)
      board.mark(2)
      board.mark(0)
      board.mark(14)
      board.mark(21)
      board.mark(17)
      board.mark(4)
      board.mark(24)
      assert_equal 4512, board.score
    end

    def test_running_game
      numbers = [1]
      boards = [
        [[1, 1, 1, 1, 1],
         [0, 2, 0, 0, 0],
         [0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0]],
        [[0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0]]
      ].map(&:to_bingo_board)

      game = BingoGame.new(numbers, boards)

      assert_equal 2, game.winning_score
    end

    def test_part_one
      input = File.read("day_four_input.txt")
      parts = input.split("\n\n")
      drawn_numbers = parts.shift.split(",").map(&:to_i)
      boards = parts.map do |board_txt|
        rows = board_txt.split("\n").map { |row| row.split.map(&:to_i) }
        BingoBoard.new(rows)
      end
      assert_equal 27027, BingoGame.new(drawn_numbers, boards).winning_score
    end

    def test_last_winning_score
      numbers = [1, 3]
      boards = [
        [[1, 1, 1, 1, 1],
         [0, 2, 0, 0, 0],
         [0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0]],
        [[0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0],
         [3, 3, 3, 3, 3],
         [0, 0, 0, 4, 0],
         [0, 0, 0, 0, 0]]
      ].map(&:to_bingo_board)

      game = BingoGame.new(numbers, boards)

      assert_equal 12, game.last_winning_score
    end

    def test_part_two
      input = File.read("day_four_input.txt")
      parts = input.split("\n\n")
      drawn_numbers = parts.shift.split(",").map(&:to_i)
      boards = parts.map do |board_txt|
        rows = board_txt.split("\n").map { |row| row.split.map(&:to_i) }
        BingoBoard.new(rows)
      end
      assert_equal 36975, BingoGame.new(drawn_numbers, boards).last_winning_score
    end

    private

    def board
      @subject ||= BingoBoard.new(elements)
    end
  end
end

class Array
  def to_bingo_board
    DayThree::BingoBoard.new(self)
  end
end
