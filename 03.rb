#!/usr/bin/env ruby

module Day03

  class Point
    attr_reader :x, :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    def +(other)
      Point.new(@x + other.x, @y + other.y)
    end

    def to_s
      "(#{@x}, #{@y})"
    end

    def ==(other)
      @x == other.x && @y == other.y
    end

    def hash
      [@x, @y].hash
    end

    def eql?(other)
      self == other
    end

  end

  a = Point.new(1, 1)
  b = Point.new(1, 1)


  CENTRAL_PORT = Point.new(0,0)

  module Part1

    INPUT = File.readlines("03.txt")
    WIRE_1_CMDS = INPUT[0].split(",").map(&:strip)
    WIRE_2_CMDS = INPUT[1].split(",").map(&:strip)

    def self.traverse(cmds)
      positions = []
      position = Day03::CENTRAL_PORT

      cmds.each do |cmd|

        amount = cmd[1..-1].to_i

        amount.times do

          case cmd
          when /^U/
            position += Point.new(0, 1)
          when /^D/
            position += Point.new(0, -1)
          when /^L/
            position += Point.new(-1, 0)
          when /^R/
            position += Point.new(1, 0)
          else
            raise "unknown command: #{cmd}"
          end

          positions << position
        end

      end

      return positions
    end

    wire_1_positions = Part1.traverse(WIRE_1_CMDS)

    wire_2_positions = Part1.traverse(WIRE_2_CMDS)

    intersections = wire_1_positions & wire_2_positions

    puts intersections.map { |p| p.x.abs + p.y.abs }.min

  end

  module Part2

    INPUT = File.readlines("03.txt")
    WIRE_1_CMDS = INPUT[0].split(",").map(&:strip)
    WIRE_2_CMDS = INPUT[1].split(",").map(&:strip)

    def self.traverse_with_steps(cmds)
      positions = []
      positions_to_steps = {}

      position = Day03::CENTRAL_PORT

      steps = 0

      cmds.each do |cmd|

        amount = cmd[1..-1].to_i

        amount.times do

          # increment our steps
          steps += 1

          case cmd
          when /^U/
            position += Point.new(0, 1)
          when /^D/
            position += Point.new(0, -1)
          when /^L/
            position += Point.new(-1, 0)
          when /^R/
            position += Point.new(1, 0)
          else
            raise "unknown command: #{cmd}"
          end

          positions_to_steps[position] = steps unless positions_to_steps.has_key?(position)

          positions << position
        end

      end

      return positions, positions_to_steps
    end

    wire_1_positions, wire_1_positions_to_steps = Part2.traverse_with_steps(WIRE_1_CMDS)

    wire_2_positions, wire_2_positions_to_steps = Part2.traverse_with_steps(WIRE_2_CMDS)

    intersections = wire_1_positions & wire_2_positions

    puts intersections.map { |p| [p, wire_1_positions_to_steps[p] + wire_2_positions_to_steps[p]] }.min { |a, b|
      a[1] <=> b[1]
    }

  end

end