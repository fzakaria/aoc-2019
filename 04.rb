#!/usr/bin/env ruby

module Day04

  PUZZLE_INPUT_STR = "264360-746325"
  PUZZLE_INPUT_RANGE = Range.new(*"264360-746325".split("-").map(&:to_i))

  module Part1


    # crack the elves password
    # It is a six-digit number.
    # The value is within the range given in the input
    # Two adjacent digits are the same (like 22 in 122345).
    # Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679)
    def self.crack_password(input_range)
      input_range.select { |input| self.has_adjacent_digits(input) && self.is_increasing(input) }.count
    end

    def self.is_increasing(number)
      number.to_s.split('').each_cons(2).all? { |a, b| a <= b }
    end

    def self.has_adjacent_digits(number)
      return number.to_s.split('').each_cons(2).any? { |a, b| a == b }
    end

    puts self.crack_password(PUZZLE_INPUT_RANGE)

  end

  module Part2

    def self.has_adjacent_digits(number)
      return number.to_s.split('').chunk { |n| n }.any? { | _, v| v.size == 2 }
    end

    def self.crack_password(input_range)
      input_range.select { |input| self.has_adjacent_digits(input) && Part1.is_increasing(input) }.count
    end

    puts self.crack_password(PUZZLE_INPUT_RANGE)

  end


end