require "minitest/autorun"
require "pry"

PUZZLE_INPUT = File.read("./day_06.input.txt")

class OrbitTest < Minitest::Test
  def test_part_one_example
    test_input = <<~TEST_INPUT
      COM)B
      B)C
      C)D
      D)E
      E)F
      B)G
      G)H
      D)I
      E)J
      J)K
      K)L
    TEST_INPUT
    assert_equal 42, SolarSystem.generate(test_input).total_orbits
  end

  def test_find_part_one_answer
    assert_equal 261306, SolarSystem.generate(PUZZLE_INPUT).total_orbits
  end

  def test_part_two_exampl
    test_input = <<~TEST_INPUT
      COM)B
      B)C
      C)D
      D)E
      E)F
      B)G
      G)H
      D)I
      E)J
      J)K
      K)L
      K)YOU
      I)SAN
    TEST_INPUT

    you = Planet.new("YOU")
    santa = Planet.new("SAN")
    assert_equal 4, SolarSystem.generate(test_input).orbital_transfers_required(you, santa)
  end

  def test_find_part_two_answer
    you = Planet.new("YOU")
    santa = Planet.new("SAN")
    assert_equal 382, SolarSystem.generate(PUZZLE_INPUT).orbital_transfers_required(you, santa)
  end
end

Planet = Struct.new(:name)

Orbit = Struct.new(:body, :satellite) do
  def self.generate(line)
    body, satellite = line.split(")").map { |name| Planet.new(name) }
    new(body, satellite)
  end
end

class SolarSystem
  def self.generate(input)
    orbits = input.lines.map { |l| Orbit.generate(l.chomp) }
    new(orbits: orbits)
  end

  attr_reader :graph

  def initialize(orbits: [])
    @graph = orbits.each_with_object({}) do |orbit, hash|
      hash[orbit.satellite] = orbit.body
    end
  end

  def total_orbits
    graph.keys.map { |p| path_to_root(p).size }.reduce(&:+)
  end

  def orbital_transfers_required(left, right)
    left_path = path_to_root(left)
    right_path = path_to_root(right)
    convergence_planet = (left_path & right_path).first
    left_path = path_to_root(left).take_while { |planet| planet != convergence_planet }
    right_path = path_to_root(right).take_while { |planet| planet != convergence_planet }
    left_path.size + right_path.size - 2
  end

  private

  def path_to_root(planet)
    return [] if root?(planet)
    [planet] + path_to_root(find_body(planet))
  end

  def root?(planet)
    find_body(planet).nil?
  end

  def find_body(planet)
    graph[planet]
  end
end
