require "minitest/autorun"

def easy_digits(output)
  output.map(&:length).count { |length| [2,4,3,7].include?(length) }
end

class SevenSegmentMap
  def initialize(input)
    @input = input.map { |s| s.chars.sort.join }
    initialize_unique_length_digits
    determine_six
    determine_zero_and_nine
    determine_three
    determine_two_and_five
  end

  def [](segment_string)
    @segments_to_i[segment_string.chars.sort.join]
  end

  private

  def initialize_unique_length_digits
    @segments_to_i = {}
    @ints_to_segments = {}
    @input.each do |segment|
      case segment.length
      when 2
        add(segment, 1)
      when 4
        add(segment, 4)
      when 3
        add(segment, 7)
      when 7
        add(segment, 8)
      end
    end
  end

  def determine_six
    segment = @input.select { |segment| segment.length == 6 }.detect { |segment| !subset_of?(@ints_to_segments[1], segment) }
    add(segment, 6)
  end

  def determine_zero_and_nine
    zero_or_nine = @input.select { |segment| segment.length == 6 && @segments_to_i[segment].nil? }
    nine, zero = zero_or_nine.partition { |segment| subset_of?(@ints_to_segments[4], segment) }.map(&:first)
    add(zero, 0)
    add(nine, 9)
  end

  def determine_three
    segment = @input.select { |segment| segment.length == 5 }.detect { |segment| subset_of?(@ints_to_segments[1], segment) }
    add(segment, 3)
  end

  def determine_two_and_five
    five, two = @input.select { |segment| @segments_to_i[segment].nil? }.partition { |segment| subset_of?(segment, @ints_to_segments[6]) }.map(&:first)
    add(five, 5)
    add(two, 2)
  end

  def add(segment, integer)
    @segments_to_i[segment] = integer
    @ints_to_segments[integer] = segment
  end

  def subset_of?(subsegment, segment)
    subsegment.chars.all? { |c| segment.include?(c) }
  end
end

class DayEightTest < Minitest::Test
  def test_counting_easy_digits_in_output
    input = 'be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe'
    output_digits = input.split(' | ').last.split
    assert_equal(2, easy_digits(output_digits))
  end

  def test_part_one
    input = File.read('test/day_eight_input.txt')
    output_digit_lines = input.split("\n").map { |line| line.split(' | ').last.split }
    assert_equal(274, output_digit_lines.sum { |output_digits| easy_digits(output_digits) })
  end

  def test_mapping_easy_digits
    input = 'acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab'.split
    map = SevenSegmentMap.new(sample_input)
    assert_equal(1, map['ab'])
    assert_equal(7, map['dab'])
    assert_equal(8, map['acedgfb'])
    assert_equal(4, map['eafb'])
  end

  def test_mapping_six
    map = SevenSegmentMap.new(sample_input)
    assert_equal(6, map['cdfgeb'])
  end

  def test_zero_and_nine
    map = SevenSegmentMap.new(sample_input)
    assert_equal(0, map['cagedb'])
    assert_equal(9, map['cefabd'])
  end

  def test_three
    map = SevenSegmentMap.new(sample_input)
    assert_equal(3, map['fbcad'])
  end

  def test_two_and_five
    map = SevenSegmentMap.new(sample_input)
    assert_equal(2, map['gcdfa'])
    assert_equal(5, map['cdfbe'])
  end

  def test_calculating_output
    map = SevenSegmentMap.new(sample_input)
    output = 'cdfeb fcadb cdfeb cdbaf'
    assert_equal('5353', output.split.map { |segment| map[segment].to_s }.join)
  end

  def test_part_two
    input = File.read('test/day_eight_input.txt').split("\n")
    result = input.map do |line|
      input_segments, output_segments = line.split(' | ')
      map = SevenSegmentMap.new(input_segments.split)
      output_segments.split.map { |segment| map[segment].to_s }.join.to_i
    end.sum
    assert_equal(1012089, result)
  end

  def sample_input
    'acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab'.split
  end
end
