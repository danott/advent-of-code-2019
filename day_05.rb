require "minitest/autorun"
require_relative "./intcode_computer"

class OpcodeTest < Minitest::Test
  EXAMPLES = {
    [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50] => [3_500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50],
    [1, 0, 0, 0, 99] => [2, 0, 0, 0, 99],
    [2, 3, 0, 3, 99] => [2, 3, 0, 6, 99],
    [2, 4, 4, 5, 99, 0] => [2, 4, 4, 5, 99, 9_801],
    [1, 1, 1, 4, 99, 5, 6, 0, 99] => [30, 1, 1, 4, 2, 5, 6, 0, 99],
    [1_101, 100, -1, 4, 0] => [1_101, 100, -1, 4, 99],
  }

  def test_examples
    EXAMPLES.each do |input_state, expected_state|
      computer = IntcodeComputer.new(state: input_state)
      computer.run
      assert_equal expected_state, computer.state
    end
  end

  def test_part_one_find_diagnostic_code
    puzzle_input = File.read("./day_05.input.txt").split(",").map(&:to_i)
    computer = IntcodeComputer.new(state: puzzle_input, input: [1]).run
    assert_equal 4_887_191, computer.diagnostic_code
  end

  def test_part_two_example
    state = [
      3,
      21,
      1_008,
      21,
      8,
      20,
      1_005,
      20,
      22,
      107,
      8,
      21,
      20,
      1_006,
      20,
      31,
      1_106,
      0,
      36,
      98,
      0,
      0,
      1_002,
      21,
      125,
      20,
      4,
      20,
      1_105,
      1,
      46,
      104,
      999,
      1_105,
      1,
      46,
      1_101,
      1_000,
      1,
      20,
      4,
      20,
      1_105,
      1,
      46,
      98,
      99,
    ]
    input_less_than_eight = IntcodeComputer.new(state: state, input: [7]).run
    input_exactly_eight = IntcodeComputer.new(state: state, input: [8]).run
    input_greater_than_eight = IntcodeComputer.new(state: state, input: [9]).run
    assert_equal 999, input_less_than_eight.diagnostic_code
    assert_equal 1_000, input_exactly_eight.diagnostic_code
    assert_equal 1_001, input_greater_than_eight.diagnostic_code
  end

  def test_part_two_find_diagnostic_code
    puzzle_input = File.read("./day_05.input.txt").split(",").map(&:to_i)
    computer = IntcodeComputer.new(state: puzzle_input, input: [5]).run
    assert_equal 3_419_022, computer.diagnostic_code
  end
end

