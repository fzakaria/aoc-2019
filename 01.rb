#!/usr/bin/env ruby
# https://adventofcode.com/2019/day/1

# Fuel required to launch a given module is based on its mass
# to find the fuel required for a module, take its mass, divide by three, round down, and subtract 2.
#
# For example:
#   For a mass of 12, divide by 3 and round down to get 4, then subtract 2 to get 2.
#   For a mass of 14, dividing by 3 and rounding down still yields 4, so the fuel required is also 2.
#   For a mass of 1969, the fuel required is 654.
#   For a mass of 100756, the fuel required is 33583.
#
# The Fuel Counter-Upper needs to know the total fuel requirement.
# To find it, individually calculate the fuel needed for the mass of
# each module (your puzzle input), then add together all the fuel values.
#
# What is the sum of the fuel requirements for all of the modules on your spacecraft?
#
#
#

module Day01

  INPUT = File.open("01.txt", "r") do |f|
    f.read.split.map(&:to_i)
  end


  module Part1

    # each input is a module
    total_fuel = Day01::INPUT.inject(0) do |sum, m|
      fuel = (m/3).floor - 2
      sum + fuel
    end

    puts total_fuel

  end

  # PART 2
  # for the fuel take its mass, divide by three, round down, and subtract 2.
  #
  module Part2

    def self.calculate_fuel(mass)
      fuel = (mass/3).floor - 2
      if fuel <= 0
        return 0
      end

      fuel + self.calculate_fuel(fuel)
    end

    total_fuel = Day01::INPUT.inject(0) do |sum, m|
      sum + self.calculate_fuel(m)
    end

    puts total_fuel

  end
end