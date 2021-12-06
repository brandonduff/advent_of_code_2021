require 'minitest/autorun'

def tick(fish)
  birthed = 0
  result = fish.map do |f|
    if f == 0
      birthed += 1
      6
    else
      f - 1
    end
  end
  birthed.times { result << 8 }
  result
end

class FishCounts
  def initialize(fish)
    @fish = fish
    initialize_counts
  end

  def [](days_left)
    @counts[days_left]
  end

  def tick
    last_value = 0
    birthed = @counts[0]
    1.upto(8).each do |i|
      @counts[last_value] = @counts[i]
      last_value += 1
    end
    @counts[8] = birthed
    @counts[6] += birthed
  end

  def total
    @counts.values.sum
  end

  private

  def initialize_counts
    @counts = Hash.new(0)
    @fish.tally.each do |key, val|
      @counts[key] = val
    end
  end
end

class DaySixTest < Minitest::Test
  def test_ticking
    fish = [3,5]
    next_fish = tick(fish)
    assert_equal([2,4], next_fish)
  end

  def test_spawning_new
    fish = [0,5]
    next_fish = tick(fish)
    assert_equal([6,4,8], next_fish)
  end

  def test_part_one
    fish = initial_fish
    80.times do
      fish = tick(fish)
    end
    assert_equal(355386, fish.count)
  end

  def test_fish_counts
    fish_counts = FishCounts.new([3,5])
    fish_counts.tick
    assert_equal(1, fish_counts[2])
    assert_equal(1, fish_counts[4])
  end

  def test_spawning_with_fish_counts
    fish_counts = FishCounts.new([0,5])
    fish_counts.tick
    assert_equal(1, fish_counts[6])
    assert_equal(1, fish_counts[4])
    assert_equal(1, fish_counts[8])
  end

  def test_counting_spawns_and_existing
    fish_counts = FishCounts.new([0,7,8,6])
    fish_counts.tick
    assert_equal(2, fish_counts[6])
    assert_equal(1, fish_counts[7])
    assert_equal(1, fish_counts[5])
    assert_equal(1, fish_counts[8])
  end

  def test_fish_counts_with_counts_greater_than_one
    fish_counts = FishCounts.new([3,5,3])
    fish_counts.tick
    assert_equal(2, fish_counts[2])
    assert_equal(1, fish_counts[4])
  end

  def test_totaling_fish_counts
    fish_counts = FishCounts.new([3,4,3,1,0])
    assert_equal(5, fish_counts.total)
  end

  def test_part_two
    fish = initial_fish
    fish_counts = FishCounts.new(initial_fish)
    256.times do
      fish_counts.tick
    end
    assert_equal(0, fish_counts.total)
  end

  def initial_fish
    File.read('day_six_input.txt').split(',').map(&:to_i)
  end
end
