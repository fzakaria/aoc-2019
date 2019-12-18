#!/usr/bin/env ruby

require 'set'

module Day10

  EMPTY = "."

  ASTEROID = "#"

  # The asteroids can be described with X,Y coordinates where X is the distance from the left edge and Y is the
  # distance from the top edge (so the top-left corner is 0,0 and the position immediately to its right is 1,0).

  # The best location is the asteroid that can detect the largest number of other asteroids.
  SPACE = File.readlines("10.example.txt").map {|row| row.strip.split("") }

  ROWS = SPACE.size

  COLUMNS = SPACE[0].size

  BEST_POINT = nil

  class Point
    attr_accessor :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def -(other)
      Point.new(@x - other.x, @y - other.y)
    end

    def ==(other)
      @x == other.x && @y == other.y
    end

    alias eql? ==

    def hash
      [@x, @y].hash
    end

    def to_s
      "(#{@x}, #{@y})"
    end
  end

  module Part1

    def self.line_enumerator(starting_point, other_point, &blk)
      # slope (m) is = y2 - y1 / x2 - x1 => p / q
      p = other_point.y - starting_point.y
      q = other_point.x - starting_point.x
      gcd = p.gcd(q)
      # reduce to lowest terms
      p = p / gcd
      q = q / gcd
      # create an enumerator that walks the line
      enumerator = Enumerator.new do |y|
        current_point = Point.new(starting_point.x, starting_point.y)

        loop do
          current_point = Point.new(current_point.x, current_point.y)
          current_point.x += q
          current_point.y += p
          y << current_point
        end
      end

      enumerator.each do |elem|
        blk.call(elem)
      end
    end

    VISIBILITY = []

    def self.calculate_visibility(starting_point)

      # create the debug view
      debug = Array.new(ROWS) { Array.new(COLUMNS) }
      debug.each { |row| row.fill(".") }

      # go through every pair
      # and calculate the line
      visibility = 0
      seen = Set.new

      SPACE.each_with_index do |row, y|
        row.each_with_index do |item, x|

          current_point = Point.new(x,y)

          # skip non asteroids
          next if item == EMPTY

          # skip ourselves
          next if current_point == starting_point

          # skip if we've processed this line before
          next if seen.include?(current_point)

          # enumerate every integer on this line
          found = false
          self.line_enumerator(starting_point, current_point) do |other_point|
            break unless other_point.x < COLUMNS && other_point.y < ROWS && other_point.x >= 0 && other_point.y >= 0

            # skip if we've processed this line before
            next if seen.include?(other_point)

            unless found
              found = true
              visibility += 1

              raise "We are double counting!" if debug[other_point.y][other_point.x] == ASTEROID
              debug[other_point.y][other_point.x] = ASTEROID
            end
            seen.add(other_point)
          end

        end
      end

      return debug, visibility
    end

    def self.print_debug(debug)
      str = ""
      debug.each do |row|
        row.each do |elem|
          str +=  "#{elem} "
        end
        str += "\n"
      end
      str
    end

    # lets go through every asteroid and calculate it's visibility
    SPACE.each_with_index do |row, y|
      row.each_with_index do |item, x|

        # skip non asteroids
        if item == EMPTY
          next
        end

        debug, visibility = self.calculate_visibility(Point.new(x, y))

        VISIBILITY << [visibility, debug, Point.new(x, y)]
      end

    end

    visibility, debug, Day10::BEST_POINT = VISIBILITY.max do |a, b|
      a[0] <=> b[0]
    end

    puts self.print_debug(debug)
    puts visibility
    puts Day10::BEST_POINT

  end

  module Part2


    # keep looping until we vaporize all the asteroids!
    def self.vaporize(starting_position)
      # create the debug view
      debug = Array.new(ROWS) { Array.new(COLUMNS) }
      debug.each { |row| row.fill(".") }

      vaporizers = Hash.new{|h,k| h[k] = [] }

      SPACE.each_with_index do |row, y|
        row.each_with_index do |item, x|

          current_point = Point.new(x,y)

          # skip non asteroids
          next if item == EMPTY

          # skip ourselves
          next if current_point == starting_position

          # atan2 takes (y, x) and gives the angle
          # to the positive x-axis
          theta = Math::PI/2 + Math.atan2(current_point.y - starting_position.y, current_point.x - starting_position.x, )
          theta = theta % (2 * Math::PI/2)

          vaporizers[theta] << current_point
        end
      end

      vaporizers.transform_values do |arr|
        arr.sort do |a, b|
          d1 = Math.sqrt( (a.x - starting_position.x)**2 + (a.y - starting_position.y)**2)
          d2 = Math.sqrt( (b.x - starting_position.x)**2 + (b.y - starting_position.y)**2)
          d2 <=> d1
        end
      end

      vaporizers.sort
    end

    vaporizers = self.vaporize(Day10::BEST_POINT)

    count = 0
    while count != 200

      vaporizers.each do |key, value|
        count += 1
        elem = value.shift
        if (count == 200)
          puts "Found it! #{elem}"
        end
        if value.empty?
          vaporizers.delete(key)
        end
      end

    end

  end

end