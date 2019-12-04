require "minitest/autorun"

class RequiredFuelTest < Minitest::Test
  def test_required_fuel
    assert_equal(2, required_fuel(12))
    assert_equal(2, required_fuel(14))
    assert_equal(654, required_fuel(1_969))
    assert_equal(33_583, required_fuel(100_756))
  end

  def test_recursive_required_fuel
    assert_equal(2, recursive_required_fuel(12))
    assert_equal(966, recursive_required_fuel(1_969))
    assert_equal(50_346, recursive_required_fuel(100_756))
  end
end

def required_fuel(mass)
  fuel = (mass / 3).floor - 2
  fuel > 0 ? fuel : 0
end

def recursive_required_fuel(mass)
  return 0 if mass.zero?
  fuel = required_fuel(mass)
  fuel + recursive_required_fuel(fuel)
end

masses = File.read("./day_01.input.txt").lines.map(&:to_i).reject(&:zero?)
total_fuel = masses.reduce(0) { |total, mass| total + required_fuel(mass) }
total_recursive_fuel = masses.reduce(0) { |total, mass| total + recursive_required_fuel(mass) }

puts "🎄" * 40
puts "TOTAL FUEL: #{total_fuel}"
puts "TOTAL RECURSIVE FUEL: #{total_recursive_fuel}"
puts "🎄" * 40
