class IntcodeComputer
  attr_reader :state
  attr_reader :input
  attr_reader :output
  attr_reader :halted
  attr_accessor :position

  def initialize(state: [], input: [])
    @state = state
    @input = input

    @output = []
    @position = 0
    @halted = false
  end

  def run
    while instruction = next_instruction
      execute(instruction)
    end
    self
  end

  def next_instruction
    return if halted
    Instruction.generate(state[position, 4])
  end

  def execute(instruction)
    instruction.execute(self)
  end

  def halt
    @halted = true
  end

  def gets
    fail "No more input provided" if input.empty?
    input.shift
  end

  def puts(value)
    output << value
  end

  def diagnostic_code
    return unless halted
    output.last
  end
end

class Paramter
  def self.generate(mode:, value:)
    case mode
    when 0
      PositionParameter.new(value)
    when 1
      ImmediateParameter.new(value)
    else
      fail "Unrecognized mode: #{mode}"
    end
  end
end

class ImmediateParameter
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def resolve(_state)
    value
  end
end

class PositionParameter
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def resolve(state)
    state[value]
  end
end

class InstructionParser
  attr_reader :opcode
  attr_reader :parameters

  def initialize(state)
    opcode_chars = state.first.to_s.rjust(5, "0").chars
    @opcode = opcode_chars.last(2).join.to_i
    parameter_modes = opcode_chars.first(3).map(&:to_i).reverse
    raw_parameters = state[1, 3]
    @parameters =
      parameter_modes.zip(raw_parameters).map do |mode, value|
        Paramter.generate(mode: mode, value: value)
      end
  end
end

module Instruction
  module Registry
    def self.extended(other)
      classes << other
    end

    def self.classes
      @@classes ||= []
    end

    def opcode(value = :called_as_getter)
      if value == :called_as_getter
        @opcode
      else
        @opcode = value
      end
    end

    def arity(value = :called_as_getter)
      if value == :called_as_getter
        @arity
      else
        @arity = value
      end
    end
  end

  def self.included(other)
    other.extend(Registry)
  end

  def self.generate(state)
    parser = InstructionParser.new(state)
    klass = Registry.classes.find { |candidate| candidate.opcode == parser.opcode }
    klass.new(parameters: parser.parameters.take(klass.arity))
  end

  attr_reader :parameters

  def initialize(parameters:)
    @parameters = parameters
  end

  def output_address
    parameters.last.value
  end

  def length
    parameters.length + 1
  end

  private

  def resolve_parameters(computer_state)
    parameters.map { |p| p.resolve(computer_state) }
  end
end

class Add
  include Instruction

  opcode 1
  arity 3

  def execute(computer)
    left, right = resolve_parameters(computer.state)
    computer.state[output_address] = left + right
    computer.position += length
    self
  end
end

class Multiply
  include Instruction

  opcode 2
  arity 3

  def execute(computer)
    left, right = resolve_parameters(computer.state)
    computer.state[output_address] = left * right
    computer.position += length
    self
  end
end

class Input
  include Instruction

  opcode 3
  arity 1

  def execute(computer)
    computer.state[output_address] = computer.gets
    computer.position += length
    self
  end
end

class Output
  include Instruction

  opcode 4
  arity 1

  def execute(computer)
    value = resolve_parameters(computer.state).first
    computer.puts value
    computer.position += length
    self
  end
end

class JumpIfTrue
  include Instruction

  opcode 5
  arity 2

  def execute(computer)
    first, second = resolve_parameters(computer.state)
    if first.zero?
      computer.position += length
    else
      computer.position = second
    end
  end
end

class JumpIfFalse
  include Instruction

  opcode 6
  arity 2

  def execute(computer)
    first, second = resolve_parameters(computer.state)
    if first.zero?
      computer.position = second
    else
      computer.position += length
    end
  end
end

class LessThan
  include Instruction

  opcode 7
  arity 3

  def execute(computer)
    first, second = resolve_parameters(computer.state)
    computer.state[output_address] = first < second ? 1 : 0
    computer.position += length
  end
end

class Equals
  include Instruction

  opcode 8
  arity 3

  def execute(computer)
    first, second = resolve_parameters(computer.state)
    computer.state[output_address] = first == second ? 1 : 0
    computer.position += length
  end
end

class Halt
  include Instruction

  opcode 99
  arity 0

  def execute(computer)
    computer.halt
    computer.position += length
  end
end