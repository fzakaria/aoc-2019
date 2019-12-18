#!/usr/bin/env ruby

module Day11

  class HaltException < Exception

  end

  class Point
    attr_accessor :x, :y

    def initialize(x, y)
      @x, @y = x, y
    end

    def -(other)
      Point.new(@x - other.x, @y - other.y)
    end

    def +(other)
      Point.new(@x + other.x, @y + other.y)
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

  # the parameter to be interpreted as a position - if the parameter is 50, its value is the value stored at address 50 in memory
  POSITION_MODE = 0
  # in immediate mode, a parameter is interpreted as a value - if the parameter is 50, its value is simply 50
  IMMEDIATE_MODE = 1
  # the parameter is interpreted as a position. Like position mode, parameters in relative mode can be read from or written to.
  RELATIVE_MODE = 2

  def self.write_address_mode(mode, parameter, relative_base)
    if mode == POSITION_MODE
      return parameter
    elsif mode == IMMEDIATE_MODE
      raise "Destination parameter in immediate mode"
    elsif mode == RELATIVE_MODE
      return parameter + relative_base
    else
      raise "Unknown addressing mode"
    end
  end

  def self.read_address_mode(memory, mode, parameter, relative_base)
    if mode == POSITION_MODE
      return memory[parameter]
    elsif mode == IMMEDIATE_MODE
      return parameter
    elsif mode == RELATIVE_MODE
      return memory[parameter + relative_base]
    else
      raise "Unknown addressing mode"
    end
  end

  def self.int_code(memory, pc = 0, relative_base = 0, input)

    while pc < memory.size

      instruction = memory[pc]

      opcode = instruction % 100

      modes = instruction.digits.drop(2)

      # if the 10th thousandth digit is missing
      # make it 0
      while modes.size < 3
        modes << 0
      end

      # Opcode 1 adds together numbers read from two positions and stores the result in a third position.
      if opcode == 1
        # Parameters that an instruction writes to will never be in immediate mode.
        memory[write_address_mode(modes[2], memory[pc + 3], relative_base)] = read_address_mode(memory, modes[0], memory[pc + 1], relative_base) + read_address_mode(memory, modes[1], memory[pc + 2], relative_base)

        pc += 4
        next
      end

      # Opcode 2 works exactly like opcode 1, except it multiplies the two inputs instead of adding them.
      if opcode == 2
        # Parameters that an instruction writes to will never be in immediate mode.
        memory[write_address_mode(modes[2], memory[pc + 3], relative_base)] = read_address_mode(memory, modes[0], memory[pc + 1], relative_base) * read_address_mode(memory, modes[1], memory[pc + 2], relative_base)

        pc += 4
        next
      end

      # Opcode 3 takes a single integer as input and saves it to the position given by its only parameter.
      # For example, the instruction 3,50 would take an input value and store it at address 50.
      if opcode == 3
        memory[write_address_mode(modes[0], memory[pc + 1], relative_base)] = input

        pc += 2
        next
      end

      # Opcode 4 outputs the value of its only parameter.
      # For example, the instruction 4,50 would output the value at address 50.
      if opcode == 4
        output = read_address_mode(memory, modes[0], memory[pc + 1], relative_base)

        pc += 2
        return pc, relative_base, output
        #next
      end

      # Opcode 5 is jump-if-true: if the first parameter is non-zero,
      # it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
      if opcode == 5
        if read_address_mode(memory, modes[0], memory[pc + 1], relative_base) != 0
          pc = read_address_mode(memory, modes[1], memory[pc + 2], relative_base)
        else
          pc += 3
        end

        next
      end

      # Opcode 6 is jump-if-false: if the first parameter is zero, it sets the instruction pointer
      # to the value from the second parameter. Otherwise, it does nothing.
      if opcode == 6
        if read_address_mode(memory, modes[0], memory[pc + 1], relative_base) == 0
          pc = read_address_mode(memory, modes[1], memory[pc + 2], relative_base)
        else
          pc += 3
        end

        next
      end

      # Opcode 7 is less than: if the first parameter is less than the second parameter,
      # it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
      if opcode == 7
        if read_address_mode(memory, modes[0], memory[pc + 1], relative_base) < read_address_mode(memory, modes[1], memory[pc + 2], relative_base)
          memory[write_address_mode(modes[2], memory[pc + 3], relative_base)] = 1
        else
          memory[write_address_mode(modes[2], memory[pc + 3], relative_base)] = 0
        end

        pc += 4
        next
      end

      # Opcode 8 is equals: if the first parameter is equal to the second parameter,
      # it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
      if opcode == 8
        if read_address_mode(memory, modes[0], memory[pc + 1], relative_base) == read_address_mode(memory, modes[1], memory[pc + 2], relative_base)
          memory[write_address_mode(modes[2], memory[pc + 3], relative_base)] = 1
        else
          memory[write_address_mode(modes[2], memory[pc + 3], relative_base)] = 0
        end

        pc += 4
        next
      end

      # Opcode 9 adjusts the relative base by the value of its only parameter.
      # The relative base increases (or decreases, if the value is negative) by the value of the parameter.
      if opcode == 9
        relative_base += read_address_mode(memory, modes[0], memory[pc + 1], relative_base)
        pc += 2
        next
      end

      if opcode == 99
        raise Day11::HaltException
      end

      raise "Unknown opcode: #{opcode}"
    end

    raise "should have seen opcode 99"
  end

  BLACK = 0
  WHITE = 1

  UP = 1
  DOWN = 2
  LEFT = 3
  RIGHT = 4

  # a 0 means it should turn left 90 degress
  def self.turn_counter_clockwise(direction)
    if direction == UP
      return LEFT
    elsif direction == DOWN
      return RIGHT
    elsif direction == LEFT
      return DOWN
    elsif direction ==RIGHT
      return UP
    end
  end

  # a 1 means it should turn right 90 degress
  def self.turn_clockwise(direction)
    if direction == UP
      return RIGHT
    elsif direction == DOWN
      return LEFT
    elsif direction == LEFT
      return UP
    elsif direction ==RIGHT
      return DOWN
    else
      raise "Unknown direction: #{direction}"
    end
  end

  def self.padright!(a, n, x)
    a.fill(x, a.length...n)
  end

  # provide 0 if the robot is over a black panel or 1 if the robot is over a white panel.
  # Then, the program will output two values:
  #
  # First, it will output a value indicating the color to paint
  # the panel the robot is over: 0 means to paint the panel black, and 1 means to paint the panel white.
  #
  # Second, it will output a value indicating the direction the robot should turn:
  # 0 means it should turn left 90 degrees, and 1 means it should turn right 90 degrees.
  #
  # After the robot turns, it should always move forward exactly one panel. The robot starts facing up.
  #
  # The robot will continue running for a while like this and halt when it is finished drawing.
  # Do not restart the Intcode computer inside the robot during this process.
  #
  module Part1

    # starting values
    point = Point.new(0, 0)
    direction = UP
    panels = Hash.new
    pc = 0
    relative_base = 0
    instructions = File.read("11.txt").split(",").map(&:strip).map(&:to_i)
    Day11.padright!(instructions, 10_000, 0)

    begin
      while true do
        input = panels.fetch(point, BLACK)
        pc, relative_base, color = Day11.int_code(instructions, pc, relative_base, input)
        pc, relative_base, turn = Day11.int_code(instructions, pc, relative_base,  nil)

        if turn == 0
          direction = Day11.turn_counter_clockwise(direction)
        elsif turn ==1
          direction = Day11.turn_clockwise(direction)
        else
          raise "Unknown turn: #{turn}"
        end

        # draw the color
        panels[point] = color
        # advance the robot
        if direction == UP
          point += Point.new(0, 1)
        elsif direction == RIGHT
          point += Point.new(1, 0)
        elsif direction == DOWN
          point += Point.new(0,-1)
        elsif direction == LEFT
          point += Point.new(-1, 0)
        else
          raise "Unknown direction: #{direction}"
        end
      end
    rescue HaltException => e
      # do nothing
    end

    puts panels.keys.size

  end

  module Part2

    # starting values
    point = Point.new(0, 0)
    direction = UP
    panels = Hash.new
    pc = 0
    relative_base = 0
    instructions = File.read("11.txt").split(",").map(&:strip).map(&:to_i)
    Day11.padright!(instructions, 10_000, 0)

    first = true
    begin
      while true do

        input = panels[point]
        if input == nil
          input = WHITE if first
          input = BLACK unless first
          first = false
        end

        pc, relative_base, color = Day11.int_code(instructions, pc, relative_base, input)
        pc, relative_base, turn = Day11.int_code(instructions, pc, relative_base, nil)

        if turn == 0
          direction = Day11.turn_counter_clockwise(direction)
        elsif turn ==1
          direction = Day11.turn_clockwise(direction)
        else
          raise "Unknown turn: #{turn}"
        end

        # draw the color
        panels[point] = color
        # advance the robot
        if direction == UP
          point += Point.new(0, 1)
        elsif direction == RIGHT
          point += Point.new(1, 0)
        elsif direction == DOWN
          point += Point.new(0,-1)
        elsif direction == LEFT
          point += Point.new(-1, 0)
        else
          raise "Unknown direction: #{direction}"
        end
      end
    rescue HaltException => e
      # do nothing
    end

    puts panels.keys.size

    max_x = panels.keys.map(&:x).max
    min_x = panels.keys.map(&:x).min

    max_y = panels.keys.map(&:y).max
    min_y = panels.keys.map(&:y).min

    max_y.downto(min_y).each do |y|
      (min_x..max_x).each do |x|
        value = panels[Point.new(x, y)]
        value = ' ' if value.nil? || value == 0
        value = "#" if value == 1
        print "#{value} "
      end
      puts
    end


  end
end