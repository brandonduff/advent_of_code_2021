require 'minitest/autorun'

def median_position(list)
	list.sort[(list.length - 1) / 2]
end

def mean_position(list)
	list.sum / list.length
end

def total_fuel(list, position)
	list.sum { |point| (position - point).abs }
end	

def total_fuel_two(list, position)
	list.sum do |point|
		n = (position - point).abs
		(n * (n + 1))/2
	end
end

class DaySevenTest < Minitest::Test
	def test_sample
		input = '16,1,2,0,4,2,7,1,2,14'.split(',').map(&:to_i)
		assert_equal(2, median_position(input))
		assert_equal(37, total_fuel(input, 2))
		assert_equal(168, total_fuel_two(input, 5))
	end

	def test_part_one
		assert_equal(339321, total_fuel(file_input, median_position(file_input)))
	end

	def test_part_two
		assert_equal(95476244, total_fuel_two(file_input, mean_position(file_input)))
	end

	def file_input
		@file_input ||= File.read('day_seven_input.txt').split(',').map(&:to_i)
	end
end	