
require "minitest/autorun"
require_relative "./intcode_computer"
require "pry"

PUZZLE_INPUT = File.read("./day_09.input.txt").split(",").map(&:to_i)

class TheTest < Minitest::Test
  def test_part_one_first_example
    program = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99]
    computer = IntcodeComputer.new(state: program)
    assert_equal program, computer.run.output 
  end

  def test_part_one_second_example
    program = [1102,34915192,34915192,7,4,7,99,0]
    computer = IntcodeComputer.new(state: program)
    assert_equal 16, computer.run.last_output.to_s.length
  end

  def test_part_one_third_example
    program = [104,1125899906842624,99]
    computer = IntcodeComputer.new(state: program)
    assert_equal 1125899906842624, computer.run.last_output
  end

  def test_find_part_one_answer
    computer = IntcodeComputer.new(state: PUZZLE_INPUT, input: [1])
    assert_equal 2171728567, computer.run.last_output
  end

  def test_find_part_two_answer
    computer = IntcodeComputer.new(state: PUZZLE_INPUT, input: [2])
    assert_equal 2171728567, computer.run.output
  end
end
