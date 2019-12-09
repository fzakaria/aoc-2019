#!/usr/bin/env ruby

module Day07

  class HaltException < Exception

  end


    # They are connected such that the first amplifier's output leads to the second amplifier's input,
  # the second amplifier's output leads to the third amplifier's input, and so on.
  # The first amplifier's input value is 0, and the last amplifier's output leads to your ship's thrusters.
  module Part1

    def self.address_mode(memory, mode, parameter)
      # position mode
      if mode == 0
        return memory[parameter]
      elsif mode == 1
        return parameter
      else
        raise "Unknown addressing mode"
      end
    end

    def self.int_code(memory, inputs, pc)

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
          memory[memory[pc + 3]] = Part1.address_mode(memory, modes[0], memory[pc + 1]) + Part1.address_mode(memory, modes[1], memory[pc + 2])

          pc += 4
          next
        end

        # Opcode 2 works exactly like opcode 1, except it multiplies the two inputs instead of adding them.
        if opcode == 2
          # Parameters that an instruction writes to will never be in immediate mode.
          memory[memory[pc + 3]] = Part1.address_mode(memory, modes[0], memory[pc + 1]) * Part1.address_mode(memory, modes[1], memory[pc + 2])

          pc += 4
          next
        end

        # Opcode 3 takes a single integer as input and saves it to the position given by its only parameter.
        # For example, the instruction 3,50 would take an input value and store it at address 50.
        if opcode == 3
          memory[memory[pc + 1]] = inputs.shift

          pc += 2
          next
        end

        # Opcode 4 outputs the value of its only parameter.
        # For example, the instruction 4,50 would output the value at address 50.
        if opcode == 4
          output = memory[memory[pc + 1]]

          pc += 2
          return output, pc

          #pc += 2
          #next
        end

        # Opcode 5 is jump-if-true: if the first parameter is non-zero,
        # it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
        if opcode == 5
          if Part1.address_mode(memory, modes[0], memory[pc + 1]) != 0
            pc = Part1.address_mode(memory, modes[1], memory[pc + 2])
          else
            pc += 3
          end

          next
        end

        # Opcode 6 is jump-if-false: if the first parameter is zero, it sets the instruction pointer
        # to the value from the second parameter. Otherwise, it does nothing.
        if opcode == 6
          if Part1.address_mode(memory, modes[0], memory[pc + 1]) == 0
            pc = Part1.address_mode(memory, modes[1], memory[pc + 2])
          else
            pc += 3
          end

          next
        end

        # Opcode 7 is less than: if the first parameter is less than the second parameter,
        # it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
        if opcode == 7
          if Part1.address_mode(memory, modes[0], memory[pc + 1]) < Part1.address_mode(memory, modes[1], memory[pc + 2])
            memory[memory[pc + 3]] = 1
          else
            memory[memory[pc + 3]] = 0
          end

          pc += 4
          next
        end

        # Opcode 8 is equals: if the first parameter is equal to the second parameter,
        # it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
        if opcode == 8

          if Part1.address_mode(memory, modes[0], memory[pc + 1]) == Part1.address_mode(memory, modes[1], memory[pc + 2])
            memory[memory[pc + 3]] = 1
          else
            memory[memory[pc + 3]] = 0
          end

          pc += 4
          next
        end

        if opcode == 99
          raise HaltException.new
        end
      end

      raise "should have seen opcode 99"
    end

    MEMORY = File.read("07.txt").split(",").map(&:strip).map(&:to_i)

    # generate all phase setting possibilities
    phase_setting_possibilities = [0, 1, 2, 3, 4].permutation.to_a


    outputs = []
    phase_setting_possibilities.each do | settings |
      memory = MEMORY.dup
      input = 0 # initial input for first amplifier
      settings.each do |phase_setting|
        # output becomes the input
        output, pc = self.int_code(memory, [phase_setting, input], 0)
        input = output
      end
      outputs << input
    end

    puts outputs.max

  end

  module Part2

    MEMORY = File.read("07.txt").split(",").map(&:strip).map(&:to_i)

    # generate all phase setting possibilities
    phase_setting_possibilities = [5, 6, 7, 8, 9].permutation.to_a


    outputs = []
    phase_setting_possibilities.each do | settings |
      memory = MEMORY.dup

    input = 0 # initial input for first amplifier
      # loop until halt signal given
      begin

        pcs = [0, 0, 0, 0, 0]

        settings.each.with_index do |phase_setting, index|
          # output becomes the input
          output, pcs[index] = Part1.int_code(memory, [phase_setting, input], pcs[index])
          input = output
        end

        settings.cycle.with_index.each do |phase_setting, index|
          # output becomes the input
          output, pcs[index % 5] = Part1.int_code(memory, [input], pcs[index % 5])
          input = output
        end

      rescue HaltException => e
        outputs << input
      end
    end

    puts outputs.max

  end

end