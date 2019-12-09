#!/usr/bin/env ruby

require 'set'

module Day06

  module Part1

    # In the map data, this orbital relationship is written AAA)BBB, which means "BBB is in orbit around AAA".
    # create a dictionary where the key is a planet
    # and the value is what it orbits
    # so it would be BBB => AAA
    ORBITS = File.readlines("06.txt").map { |l| l.strip.split(")") }
        .map { |arr| [arr[1], arr[0]]}.to_h

    @memoize = {}
    def self.count_orbits(orbits, planet)
      unless orbits.has_key?(planet)
        return 0
      end

      if @memoize.has_key?(planet)
        return @memoize[planet]
      end

      return 1 + self.count_orbits(orbits, orbits[planet])
    end

    puts ORBITS.keys.map{ |planet| self.count_orbits(ORBITS, planet) }.reduce(0, :+)

  end

  module Part2

    def self.min_orbital_transfers(planets, planet, destination, visited)
      if planet == destination
        return 0
      end

      if visited.include?(planet)
       return Float::INFINITY
      end

      visited.add(planet)

      results = []
      # At this point we can try to move to any planet we are orbiting
      # or are being orbited
      #1. orbiting
      if planets.has_key?(planet)
        results << self.min_orbital_transfers(planets, planets[planet], destination, visited)
      end

      # 2. find everyone who is orbiting this planet
      planets.find_all{|_,v|v == planet}.each do |p, _|
        results << self.min_orbital_transfers(planets, p, destination, visited)
      end

      if results.empty?
        return Float::INFINITY
      end

      return results.min + 1
    end

    puts self.min_orbital_transfers(Part1::ORBITS,  Part1::ORBITS["YOU"], Part1::ORBITS["SAN"], Set.new)

  end
end