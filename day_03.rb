require "minitest/autorun"

INPUT = File.read("./day_03.input.txt")

class TheTest < Minitest::Test
  EXAMPLES = {
    "R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83" => [159, 610],
    "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\nU98,R91,D20,R16,D67,R40,U7,R15,U6,R7" => [
      135,
      410,
    ],
  }

  def test_examples
    EXAMPLES.each do |input, (part_one, part_two)|
      assert_equal part_one, minimal_manhattan_distance(input)
      assert_equal part_two, minimal_steps_to_intersection(input)
    end
  end
end

def minimal_manhattan_distance(input)
  comparison = TrailComparison.parse(input)
  manhattan_distances = comparison.intersections.map { |i| comparison.manhattan_distance(i) }
  manhattan_distances.min
end

def minimal_steps_to_intersection(input)
  comparison = TrailComparison.parse(input)
  steps_to_intersection = comparison.intersections.map { |i| comparison.steps_to_intersection(i) }
  steps_to_intersection.min
end

class TrailComparison
  attr_reader :left
  attr_reader :right

  def self.parse(input)
    left, right =
      input.split("\n").map { |s| Directions.parse(s) }.map { |d| Trail.new(directions: d).walk }
    new(left, right)
  end

  def initialize(left, right)
    @left = left
    @right = right
  end

  def intersections
    left.visits & right.visits - [Trail::STARTING_POSITION]
  end

  def manhattan_distance(intersection)
    intersection.first.abs + intersection.last.abs
  end

  def steps_to_intersection(intersection)
    left.visits.find_index(intersection) + right.visits.find_index(intersection)
  end
end

class Trail
  STARTING_POSITION = [0, 0]
  attr_reader :directions
  attr_reader :visits

  def initialize(directions:)
    @directions = directions
    @visits = [STARTING_POSITION]
  end

  def walk
    return self if @walked
    @walked = true
    current_x, current_y = visits.last

    directions.paces.each do |pace|
      pace.distance.times do
        case pace.bearing
        when "U"
          current_y += 1
        when "D"
          current_y -= 1
        when "R"
          current_x += 1
        when "L"
          current_x -= 1
        else
          fail "This shouldn't happen"
        end

        visits.push([current_x, current_y])
      end
    end

    self
  end
end

class Directions
  attr_reader :paces

  def self.parse(string)
    paces = string.split(",").map { |p| Pace.parse(p) }
    new(paces: paces)
  end

  def initialize(paces:)
    @paces = paces
  end
end

class Pace
  attr_reader :bearing
  attr_reader :distance

  def self.parse(string)
    bearing = string[0]
    distance = string[1, string.length].to_i
    new(bearing: bearing, distance: distance)
  end

  def initialize(bearing:, distance:)
    @bearing = bearing
    @distance = distance
  end
end

puts "🎄" * 40
puts "PART A ANSWER: #{minimal_manhattan_distance(INPUT)}"
puts "PART A ANSWER: #{minimal_steps_to_intersection(INPUT)}"
puts "🎄" * 40
