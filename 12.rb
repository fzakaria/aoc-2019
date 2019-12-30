#!/usr/bin/env ruby
require 'set'

module Day12

  class Moon
    attr_accessor :point, :velocity

    def initialize(point)
      @point = point
      @velocity = Point.new(0, 0, 0)
    end

    def to_s
      "Point: #{@point}, Velocity: #{@velocity}"
    end

    # A moon's potential energy is the sum of the absolute values of its x, y, and z position coordinates.
    def potential_energy
      [@point.x, @point.y, @point.z].map(&:abs).sum
    end

    # A moon's kinetic energy is the sum of the absolute values of its velocity coordinates.
    def kinetic_energy
      [@velocity.x, @velocity.y, @velocity.z].map(&:abs).sum
    end
  end

  class Point
    attr_accessor :x, :y, :z

    def initialize(x, y, z)
      @x, @y, @z = x, y, z
    end

    def -(other)
      Point.new(@x - other.x, @y - other.y, @z - other.z)
    end

    def +(other)
      Point.new(@x + other.x, @y + other.y, @z + other.z)
    end

    def ==(other)
      @x == other.x && @y == other.y && @z == other.z
    end

    alias eql? ==

    def hash
      [@x, @y, @z].hash
    end

    def to_s
      "(#{@x}, #{@y}, #{@z})"
    end
  end

  module Part1

    # Simulate the motion of the moons in time steps. Within each time step,
    # first update the velocity of every moon by applying gravity.
    # Then, once all moons' velocities have been updated,
    # update the position of every moon by applying velocity.
    # Time progresses by one step once all of the positions are updated.
    #
    # To apply gravity, consider every pair of moons.
    #
    #
    moons = File.readlines("12.txt").map do |line|
      # <x=3, y=15, z=8>
      m = line.match(/<x=(?<x>-?\d+), y=(?<y>-?\d+), z=(?<z>-?\d+)>/)
      raise "Could not match #{line}" unless m
      Moon.new(Point.new(m[:x].to_i, m[:y].to_i, m[:z].to_i))
    end

    previous_states = Set.new

    def self.tick(moons)
      moons.combination(2).each do |moon_pair|
        lhs, rhs = moon_pair

        # consider x
        if lhs.point.x < rhs.point.x
          lhs.velocity.x += 1
          rhs.velocity.x -= 1
        elsif lhs.point.x > rhs.point.x
          rhs.velocity.x += 1
          lhs.velocity.x -= 1
        end

        # consider y
        if lhs.point.y < rhs.point.y
          lhs.velocity.y += 1
          rhs.velocity.y -= 1
        elsif lhs.point.y > rhs.point.y
          rhs.velocity.y += 1
          lhs.velocity.y -= 1
        end

        # consider z
        if lhs.point.z < rhs.point.z
          lhs.velocity.z += 1
          rhs.velocity.z -= 1
        elsif lhs.point.z > rhs.point.z
          rhs.velocity.z += 1
          lhs.velocity.z -= 1
        end
      end

      # apply velocity
      moons.each do |moon|
        moon.point = moon.point + moon.velocity
      end
    end

    tick = 0
    while tick <= 1000
      tick(moons)
      tick += 1
      # The total energy for a single moon is its potential energy multiplied by its kinetic energy.
      total_energy = moons.inject(0) { |sum, moon| sum + (moon.kinetic_energy * moon.potential_energy) }
      puts "After #{tick} steps:"
      moons.each do |moon|
        puts moon
      end
      puts "Total Energy: #{total_energy}"
    end

  end

  module Part2

    # find all x
    while true

    end

  end

end
