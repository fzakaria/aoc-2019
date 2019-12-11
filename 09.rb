#!/usr/bin/env ruby

module Day09

  module Part1

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

    def self.int_code(memory, input)
      # The address a relative mode parameter refers to is itself plus the current relative base.
      relative_base = 0

      pc = 0
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
          puts read_address_mode(memory, modes[0], memory[pc + 1], relative_base)

          pc += 2
          next
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
          return
        end

        raise "Unknown opcode: #{opcode}"
      end

      raise "should have seen opcode 99"
    end

    def self.padright!(a, n, x)
      a.fill(x, a.length...n)
    end

    memory = File.read("09.txt").split(",").map(&:strip).map(&:to_i)
    self.padright!(memory, 10_000, 0)
    self.int_code(memory, 1)


  end

  module Part2

    memory = File.read("09.txt").split(",").map(&:strip).map(&:to_i)
    Part1.padright!(memory, 10_000, 0)
    Part1.int_code(memory, 2)



  end



end