require "minitest/autorun"

class OpcodeTest < Minitest::Test
  EXAMPLES = {
    [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50] => [3_500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50],
    [1, 0, 0, 0, 99] => [2, 0, 0, 0, 99],
    [2, 3, 0, 3, 99] => [2, 3, 0, 6, 99],
    [2, 4, 4, 5, 99, 0] => [2, 4, 4, 5, 99, 9_801],
    [1, 1, 1, 4, 99, 5, 6, 0, 99] => [30, 1, 1, 4, 2, 5, 6, 0, 99],
  }

  def test_examples
    EXAMPLES.each do |input_state, expected_state|
      opcode = Opcode.new(state: input_state).run
      assert_equal expected_state, opcode.state
    end
  end
end

class Opcode
  attr_reader :state
  attr_reader :position

  def initialize(state: [], position: 0)
    @state = state
    @position = position
  end

  def self.parse(string)
    state = string.split(",").map(&:to_i)
    new(state: state)
  end

  def self.run(opcode)
    opcode = opcode.next until opcode.finished?
    opcode
  end

  def finished?
    position == -1
  end

  def run
    self.class.run(self)
  end

  def next
    return self if finished?
    case state[position]
    when 99
      finish
    when 1
      add
    when 2
      multiply
    else
      fail "Unrecognized instruction: #{state[position]}"
    end
  end

  def output
    state[0]
  end

  def noun(value)
    next_state = state.dup
    next_state[1] = value
    self.class.new(state: next_state, position: position)
  end

  def verb(value)
    next_state = state.dup
    next_state[2] = value
    self.class.new(state: next_state, position: position)
  end

  private

  def finish
    self.class.new(state: state.dup, position: -1)
  end

  def add
    left_value = state[state[position + 1]]
    right_value = state[state[position + 2]]
    where_to_store_result = state[position + 3]
    next_state = state.dup
    next_state[where_to_store_result] = left_value + right_value
    self.class.new(state: next_state, position: position + 4)
  end

  def multiply
    left_value = state[state[position + 1]]
    right_value = state[state[position + 2]]
    where_to_store_result = state[position + 3]
    next_state = state.dup
    next_state[where_to_store_result] = left_value * right_value
    self.class.new(state: next_state, position: position + 4)
  end
end

initial_state = File.read("./day_02.input.txt")
initial_opcode = Opcode.parse(initial_state)

puts "🎄" * 40
puts "PART A OUTPUT: #{initial_opcode.noun(12).verb(2).run.output}"

99.times do |noun|
  99.times do |verb|
    output = initial_opcode.noun(noun).verb(verb).run.output
    if output == 19_690_720
      puts "PART B INPUTS FOUND: #{noun}, #{verb} => #{100 * noun + verb}"
      puts "🎄" * 40
      exit 0
    end
  end
end
