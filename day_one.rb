module DayOne
  module_function

  def part_one
    numbers.each_cons(2).count do |a, b|
      a < b
    end
  end

  def part_two
    numbers.each_cons(3).each_cons(2).count do |first_set, second_set|
      first_set.sum < second_set.sum
    end
  end

  def numbers
    File.read('day_one_input.txt').split("\n").map(&:to_i)
  end
end
