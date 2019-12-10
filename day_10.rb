require "minitest/autorun"
require "pry"

PUZZLE_INPUT = File.read("./day_10.input.txt")

class TheTest < Minitest::Test
  def test_example_one
    input = <<~INPUT
      .#..#
      .....
      #####
      ....#
      ...##
    INPUT

    assert_equal LineOfSight::Cell.new(3, 4, 8), LineOfSight.generate(input).max
  end

  def test_example_two
    input = <<~INPUT
      ......#.#.
      #..#.#....
      ..#######.
      .#.#.###..
      .#..#.....
      ..#....#.#
      #..#....#.
      .##.#..###
      ##...#..#.
      .#....####
    INPUT

    line_of_sight = LineOfSight.generate(input)
    assert_equal LineOfSight::Cell.new(5, 8, 33), line_of_sight.max
  end

  def test_example_three
    input = <<~INPUT
      #.#...#.#.
      .###....#.
      .#....#...
      ##.#.#.#.#
      ....#.#.#.
      .##..###.#
      ..#...##..
      ..##....##
      ......#...
      .####.###.
    INPUT

    line_of_sight = LineOfSight.generate(input)
    assert_equal LineOfSight::Cell.new(1, 2, 35), line_of_sight.max
  end

  def test_example_five
    input = <<~INPUT
      .#..##.###...#######
      ##.############..##.
      .#.######.########.#
      .###.#######.####.#.
      #####.##.#.##.###.##
      ..#####..#.#########
      ####################
      #.####....###.#.#.##
      ##.#################
      #####.##.###..####..
      ..######..##.#######
      ####.##.####...##..#
      .#####..#.######.###
      ##...#.##########...
      #.##########.#######
      .####.#.###.###.#.##
      ....##.##.###..#####
      .#.#.###########.###
      #.#.#.#####.####.###
      ###.##.####.##.#..##
    INPUT

    line_of_sight = LineOfSight.generate(input)
    assert_equal LineOfSight::Cell.new(11, 13, 210), line_of_sight.max
  end

  def test_find_answer_part_one
    line_of_sight = LineOfSight.generate(PUZZLE_INPUT)
    assert_equal 282, line_of_sight.max.observes
  end

  Point =
    Struct.new(:x, :y) do
      def self.from_cell(cell)
        new(cell.x, cell.y)
      end
    end

  def test_part_two
    input = <<~INPUT
      .#..##.###...#######
      ##.############..##.
      .#.######.########.#
      .###.#######.####.#.
      #####.##.#.##.###.##
      ..#####..#.#########
      ####################
      #.####....###.#.#.##
      ##.#################
      #####.##.###..####..
      ..######..##.#######
      ####.##.####...##..#
      .#####..#.######.###
      ##...#.##########...
      #.##########.#######
      .####.#.###.###.#.##
      ....##.##.###..#####
      .#.#.###########.###
      #.#.#.#####.####.###
      ###.##.####.##.#..##
    INPUT

    vaporization_order = LineOfSight.generate(input).vaporization_order

    assert_equal Point.new(11, 12), Point.from_cell(vaporization_order[1 - 1])
    assert_equal Point.new(12, 1), Point.from_cell(vaporization_order[2 - 1])
    assert_equal Point.new(12, 2), Point.from_cell(vaporization_order[3 - 1])
    assert_equal Point.new(12, 8), Point.from_cell(vaporization_order[10 - 1])
    assert_equal Point.new(16, 0), Point.from_cell(vaporization_order[20 - 1])
    assert_equal Point.new(16, 9), Point.from_cell(vaporization_order[50 - 1])
    assert_equal Point.new(10, 16), Point.from_cell(vaporization_order[100 - 1])
    assert_equal Point.new(9, 6), Point.from_cell(vaporization_order[199 - 1])
    assert_equal Point.new(8, 2), Point.from_cell(vaporization_order[200 - 1])
    assert_equal Point.new(10, 9), Point.from_cell(vaporization_order[201 - 1])
    assert_equal Point.new(11, 1), Point.from_cell(vaporization_order[299 - 1])
  end

  def test_find_answer_part_two
    cell = LineOfSight.generate(PUZZLE_INPUT).vaporization_order[200 - 1]
    mathed = (cell.x * 100) + cell.y
    assert_equal 1008, mathed
  end
end

class LineOfSight
  OCCUPIED = "#"

  Cell = Struct.new(:x, :y, :observes)

  def self.generate(string)
    cells =
      string.split("\n").each_with_index.flat_map do |row, y|
        row.split("").each_with_index.map do |value, x|
          next unless value == OCCUPIED
          Cell.new(x, y, 0)
        end
      end.compact

    new(cells: cells)
  end

  attr_reader :cells

  def initialize(cells:)
    @cells = cells
    cells.each do |observer|
      radians = (cells - [observer]).map { |observed| compute_radians(observer, observed) }
      observer.observes = radians.uniq.size
    end
  end

  def vaporization_order
    center = max
    targets = cells - [center]

    radians_map =
      targets.reduce({}) do |hash, target|
        key = compute_radians(center, target)
        hash[key] ||= []
        hash[key] << target
        hash
      end

    radians_map.transform_values! do |array|
      array.sort { |a, b| distance(center, a) <=> distance(center, b) }
    end

    ordered = []

    until radians_map.values.flatten.size.zero?
      radians_map.keys.sort.each do |radians|
        value = radians_map[radians].shift
        if value
          ordered << value
        else
          radians_map.delete(radians)
        end
      end
    end

    ordered
  end

  def max
    @max ||= cells.max_by(&:observes)
  end

  private

  def compute_radians(center, perimeter)
    delta_y = perimeter.y - center.y
    delta_x = perimeter.x - center.x
    radians = Math.atan2(delta_x, -delta_y)
    radians += 2 * Math::PI if radians < 0
    radians
  end

  def distance(center, perimeter)
    delta_y = perimeter.y - center.y
    delta_x = perimeter.x - center.x
    delta_y.abs + delta_x.abs
  end
end
