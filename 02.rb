#!/usr/bin/env ruby

module Day02


  def self.int_code(memory)

    for index in (0...memory.length).step(4)

      opcode = memory[index]

      # Opcode 1 adds together numbers read from two positions and stores the result in a third position.
      if opcode == 1
        memory[memory[index + 3]] = memory[memory[index + 1]] + memory[memory[index + 2]]
        next
      end

      # Opcode 2 works exactly like opcode 1, except it multiplies the two inputs instead of adding them.
      if opcode == 2
        memory[memory[index + 3]] = memory[memory[index + 1]] * memory[memory[index + 2]]
        next
      end

      if opcode == 99
        return memory[0]
      end
    end

    raise "should have seen opcode 99"
  end

  module Part1

    INPUT = File.read("02.txt").split(",").map(&:strip).map(&:to_i)

    INPUT[1] = 12
    INPUT[2] = 2

    puts Day02.int_code(INPUT)

  end

  module Part2

    # determine what pair of inputs produces the output 19690720
    INITIAL_MEMORY = File.read("02.txt").split(",").map(&:strip).map(&:to_i)
    EXPECTED_OUTPUT = 19690720

    (0..99).each do |noun|
      (0..99).each do |verb|

        memory = INITIAL_MEMORY.dup
        memory[1] = noun
        memory[2] = verb

        result = Day02.int_code(memory)
        if result == EXPECTED_OUTPUT
          puts 100 * noun + verb
          exit
        end

      end
    end
  end

end