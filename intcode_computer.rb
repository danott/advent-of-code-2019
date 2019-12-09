class IntcodeComputer
  attr_reader :state
  attr_reader :input
  attr_reader :output
  attr_reader :halted
  attr_reader :paused
  attr_accessor :position
  attr_accessor :relative_mode_base

  def initialize(state: [], input: [])
    @state = state.dup
    @input = input.dup

    @output = []
    @position = 0
    @relative_mode_base = 0
    @halted = false
  end

  def run
    resume
    while instruction = next_instruction
      instruction.execute(self)
    end
    self
  end

  def next_instruction
    return if halted
    return if paused
    Instruction.generate(state[position, 4])
  end

  def halt
    @halted = true
  end

  def gets
    return :pause if input.empty?
    input.shift
  end

  def puts(value)
    output << value
  end

  def read(address)
    fail "Invalid" if address < 0
    state[address] || 0
  end

  def pause
    @paused = true
    self
  end

  def diagnostic_code
    return unless halted
    last_output
  end

  def last_output
    output.last
  end

  private

  def resume
    @paused = false
    self
  end
end

class Parameter
  def self.generate(mode:, value:)
    case mode
    when 0
      PositionModeParameter.new(value)
    when 1
      ImmediateModeParameter.new(value)
    when 2
      RelativeModeParameter.new(value)
    else
      fail "Unrecognized mode: #{mode}"
    end
  end
end

class ImmediateModeParameter
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def resolve(_computer)
    value
  end

  def output_address(_computer)
    value
  end
end

class PositionModeParameter
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def resolve(computer)
    computer.read(value)
  end

  def output_address(_computer)
    value
  end
end

class RelativeModeParameter
  attr_reader :value

  def initialize(value)
    @value = value
  end

  def resolve(computer)
    computer.read(output_address(computer))
  end

  def output_address(computer)
    computer.relative_mode_base + value
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
        Parameter.generate(mode: mode, value: value)
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

  def length
    parameters.length + 1
  end

  def resolve_parameters(computer)
    ResolvedParameters.new(parameters: parameters, computer: computer)
  end
end

class ResolvedParameters
  attr_reader :parameters
  attr_reader :computer

  def initialize(parameters:, computer:)
    @parameters = parameters
    @computer = computer
  end

  def positional
    [first, second, output_address].compact
  end

  def first
    parameters[0].resolve(computer)
  end

  def second
    parameters[1].resolve(computer)
  end

  def output_address
    parameters.last.output_address(computer)
  end
end

class Add
  include Instruction

  opcode 1
  arity 3

  def execute(computer)
    left, right, output_address = resolve_parameters(computer).positional
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
    left, right, output_address = resolve_parameters(computer).positional
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
    output_address = resolve_parameters(computer).output_address
    value = computer.gets
    if value == :pause
      computer.pause
    else
      computer.state[output_address] = value
      computer.position += length
    end
    self
  end
end

class Output
  include Instruction

  opcode 4
  arity 1

  def execute(computer)
    value = resolve_parameters(computer).first
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
    first, second = resolve_parameters(computer).positional
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
    first, second = resolve_parameters(computer).positional
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
    first, second, output_address = resolve_parameters(computer).positional
    computer.state[output_address] = first < second ? 1 : 0
    computer.position += length
  end
end

class Equals
  include Instruction

  opcode 8
  arity 3

  def execute(computer)
    first, second, output_address = resolve_parameters(computer).positional
    computer.state[output_address] = first == second ? 1 : 0
    computer.position += length
  end
end

class AdjustRelativeBase
  include Instruction

  opcode 9
  arity 1

  def execute(computer)
    value = resolve_parameters(computer).first
    computer.relative_mode_base = computer.relative_mode_base + value
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