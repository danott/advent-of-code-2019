require "minitest/autorun"
require "pry"

PUZZLE_INPUT = File.read("./day_08.input.txt")

class TheTest < Minitest::Test
  def test_part_one_example
    example_data = "123456789012"
    expected_layers = %w[123456 789012]
    image = ElfImage.new(width: 3, height: 2, data: example_data)
    assert_equal expected_layers, image.layers
    assert_equal "123456", image.layer_with_fewest_zero_digits
    assert_equal 1, image.multiply_occurrences_in_layer_with_fewest_zero_digits
  end

  def test_find_part_one_answer
    image = ElfImage.new(width: 25, height: 6, data: PUZZLE_INPUT)
    assert_equal 2_032, image.multiply_occurrences_in_layer_with_fewest_zero_digits
  end

  def test_part_two_example
    example_data = "0222112222120000"
    expected_output = "01\n10"

    image = ElfImage.new(width: 2, height: 2, data: example_data)
    assert_equal expected_output, image.decoded
  end

  def test_find_part_two_answer
    image = ElfImage.new(width: 25, height: 6, data: PUZZLE_INPUT)
    expected = <<~EXPECTED
      0110011110011001001001100
      1001010000100101001010010
      1000011100100001001010000
      1000010000100001001010110
      1001010000100101001010010
      0110010000011000110001110
    EXPECTED
      .chomp
    assert_equal expected, image.decoded
  end

  def test_find_part_two_answer_legible
    skip
    image = ElfImage.new(width: 25, height: 6, data: PUZZLE_INPUT)
    assert_equal "failing on purpose to see decoded", make_legible_in_test_output(image.decoded)
  end

  def make_legible_in_test_output(decoded)
    "\n" + decoded.gsub("0", " ").gsub("1", "*")
  end
end

class ElfImage
  attr_reader :layers
  attr_reader :width
  attr_reader :height

  def initialize(width:, height:, data:)
    @width = width
    @height = height
    @layers = data.chars.each_slice(area).map(&:join)
  end

  def layer_with_fewest_zero_digits
    layers.sort { |a, b| a.count("0") <=> b.count("0") }.first
  end

  def multiply_occurrences_in_layer_with_fewest_zero_digits(left: "1", right: "2")
    layer = layer_with_fewest_zero_digits
    layer.count(left) * layer.count(right)
  end

  def area
    width * height
  end

  def decoded
    black, white, transparent = 0, 1, 2
    digitized_layers = layers.map { |l| l.chars.map(&:to_i) }
    final_image =
      digitized_layers.reduce do |wip_image, layer_below|
        wip_image.each_with_index do |current_color, index|
          wip_image[index] = layer_below[index] if current_color == transparent
        end
      end
    final_image.each_slice(width).map(&:join).join("\n")
  end
end
