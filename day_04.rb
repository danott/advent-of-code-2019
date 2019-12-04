require "minitest/autorun"

INPUT = 235_741..706_948

class PasswordTest < Minitest::Test
  def test_part_a
    part_a = PasswordGenerator.part_a(100_000..230_000)
    assert part_a.match?(111_111)
    refute part_a.match?(223_450)
    refute part_a.match?(123_789)
  end

  def test_part_b
    part_b = PasswordGenerator.part_b(100_000..130_000)
    refute part_b.match?(111_111)
    assert part_b.match?(112_233)
    refute part_b.match?(123_444)
    assert part_b.match?(111_122)
  end
end

class SixDigits
  def match?(integer)
    integer.to_s.length == 6
  end
end

class AlwaysIncreasing
  def match?(integer)
    chars = integer.to_s.chars
    chars.take(chars.size - 1).each_with_index.all? { |c, i| c.to_i <= chars[i + 1].to_i }
  end
end

class HasPair
  def match?(integer)
    chars = integer.to_s.chars
    chars.each_with_index.any? { |c, i| chars[i + 1] == c }
  end
end

class HasStrictPair
  def match?(integer)
    chars = integer.to_s.chars
    chars.each_with_index.any? do |c, i|
      chars[i + 1] == c && chars[i - 1] != c && chars[i + 2] != c
    end
  end
end

class PasswordGenerator
  attr_reader :range, :rules

  def self.part_a(range)
    new(range: range, rules: [SixDigits.new, AlwaysIncreasing.new, HasPair.new])
  end

  def self.part_b(range)
    new(range: range, rules: [SixDigits.new, AlwaysIncreasing.new, HasStrictPair.new])
  end

  def initialize(range:, rules:)
    @range = range
    @rules = rules
  end

  def match?(integer)
    range.include?(integer) && rules.all? { |r| r.match?(integer) }
  end

  def candidates
    range.select { |i| match?(i) }
  end
end

part_a = PasswordGenerator.part_a(INPUT)
part_b = PasswordGenerator.part_b(INPUT)

puts "🎄" * 40
puts "PART A ANSWER: #{part_a.candidates.size}"
puts "PART B ANSWER: #{part_b.candidates.size}"
puts "🎄" * 40
