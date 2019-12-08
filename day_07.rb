require "minitest/autorun"
require_relative "./intcode_computer"
require "pry"

PUZZLE_INPUT = File.read("./day_07.input.txt").split(",").map(&:to_i)

class DaySevenTest < Minitest::Test
  def test_part_one_examples
    program = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
    assert_equal 43210, FindMaxThruster.single_pass(program: program).call

    program = [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]
    assert_equal 54321, FindMaxThruster.single_pass(program: program).call

    program = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33, 1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
    assert_equal 65210, FindMaxThruster.single_pass(program: program).call
  end

  def test_find_part_one_answer
    program = PUZZLE_INPUT
    assert_equal 368584, FindMaxThruster.single_pass(program: program).call
  end

  def test_part_two_examples
    program = [3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26, 27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5]
    assert_equal 139629729, FindMaxThruster.feedback_loop(program: program).call

    program = [3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54, -5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4, 53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10]
    assert_equal 18216, FindMaxThruster.feedback_loop(program: program).call
  end

  def test_find_part_two_answer
    program = PUZZLE_INPUT
    assert_equal 35993240, FindMaxThruster.feedback_loop(program: program).call
  end
end

class Amplifier
  attr_reader :computer
  attr_reader :phase

  def initialize(program:, phase:, signal: nil)
    @phase = phase
    @computer = IntcodeComputer.new(state: program, input: [phase])
    change_signal(signal)
  end

  def output
    computer.run.last_output
  end

  def change_signal(next_signal)
    return if next_signal.nil?
    computer.input << next_signal
  end
end

class AmplifierDaisyChain
  attr_reader :program
  attr_reader :phases

  def initialize(program:, phases:)
    @program = program
    @phases = phases
  end

  def output
    phases.reduce(0) do |current_signal, phase|
      Amplifier.new(program: program, phase: phase, signal: current_signal).output
    end
  end
end

class AmplifierLoop
  attr_reader :amplifiers

  def initialize(program:, phases:)
    @amplifiers = phases.map { |phase| Amplifier.new(program: program.dup, phase: phase) }
    @amplifiers.first.change_signal(0)
  end

  def output
    current_amplifier = amplifiers.first
    until amplifiers.last.computer.halted
      next_amplifier = find_next_amplifier(current_amplifier)
      next_amplifier.change_signal(current_amplifier.output) 
      current_amplifier = next_amplifier
    end
    amplifiers.last.output
  end

  private

  def find_next_amplifier(amplifier)
    index = amplifiers.find_index(amplifier)
    amplifiers[index + 1] || amplifiers.first
  end
end

class FindMaxThruster
  attr_reader :amplifier_configuration
  attr_reader :phases
  attr_reader :program

  def self.single_pass(program:)
    new(program: program, phases: (0..4).to_a, amplifier_configuration: AmplifierDaisyChain)
  end

  def self.feedback_loop(program:)
    new(program: program, phases: (5..9).to_a, amplifier_configuration: AmplifierLoop)
  end

  def initialize(amplifier_configuration:, phases:, program:)
    @amplifier_configuration = amplifier_configuration
    @phases = phases
    @program = program
  end

  def call
    values = phases.permutation.map do |phase_permutation|
      amplifier_configuration.new(program: program, phases: phase_permutation).output
    end
    values.max
  end
end
