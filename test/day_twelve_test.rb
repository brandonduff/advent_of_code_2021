require 'minitest/autorun'
require 'set'

class String
  def upcase?
    self == upcase
  end
end

class Node
  attr_reader :value, :neighbors, :seen

  def initialize(value)
    @value = value
    @neighbors = []
  end

  def add_neighbor(node)
    neighbors << node
  end
end

class Nodes
  def initialize
    @elements = Set.new
  end

  def parse(line)
    from, to = line.split('-').map { |value| find(value) || Node.new(value) }
    from.add_neighbor(to)
    to.add_neighbor(from)
    @elements << from
    @elements << to
  end

  def find(value)
    @elements.detect { |element| element.value == value }
  end

  def length
    @elements.length
  end
end

class PathFinder
  def initialize(nodes)
    @nodes = nodes
  end

  def path_count
    dfs(@nodes.find('start'), [], false)
  end

  def path_count_with_reentrance
    dfs(@nodes.find('start'), [], true)
  end
end

def dfs(node, visited, option_to_revisit)
  return 1 if node.value == 'end'

  if !node.value.upcase? && visited.include?(node)
    if option_to_revisit && node.value != 'start'
      option_to_revisit = false
    else
      return 0
    end
  end

  node.neighbors.sum {|neighbor| dfs(neighbor, [*visited, node], option_to_revisit) }
end

class DayTwelveTest < Minitest::Test
  def test_adding_nodes
    nodes = Nodes.new
    nodes.parse('start-A')
    nodes.parse('start-b')

    assert_equal('b', nodes.find('start').neighbors.last.value)
    assert_equal('A', nodes.find('start').neighbors.first.value)
    assert_equal(3, nodes.length)
  end

  def test_counting_paths
    nodes = Nodes.new
    nodes.parse('start-a')
    nodes.parse('start-b')
    nodes.parse('a-end')
    nodes.parse('b-end')
    path_finder = PathFinder.new(nodes)
    assert_equal(2, path_finder.path_count)
  end

  def test_allowing_rentry_to_big_caves
    lines = <<~INPUT
      start-A
      start-b
      A-c
      A-b
      b-d
      A-end
      b-end
    INPUT
    nodes = Nodes.new
    lines.split("\n").each do |line|
      nodes.parse(line)
    end

    path_finder = PathFinder.new(nodes)
    assert_equal(10, path_finder.path_count)
  end

  def test_part_one
    file_input = File.read('day_twelve_input.txt')
    nodes = Nodes.new
    file_input.split("\n").each do |line|
      nodes.parse(line)
    end

    path_finder = PathFinder.new(nodes)
    assert_equal(4495, path_finder.path_count)
  end

  def test_allowing_reentrance
    lines = <<~INPUT
      start-A
      A-c
      A-end
    INPUT
    nodes = Nodes.new
    lines.split("\n").each do |line|
      nodes.parse(line)
    end
    path_finder = PathFinder.new(nodes)
    assert_equal(3, path_finder.path_count_with_reentrance)
  end

  def test_part_two
    file_input = File.read('day_twelve_input.txt')
    nodes = Nodes.new
    file_input.split("\n").each do |line|
      nodes.parse(line)
    end

    path_finder = PathFinder.new(nodes)
    assert_equal(131254, path_finder.path_count_with_reentrance)
  end
end
