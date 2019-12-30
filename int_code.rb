class IntCode

  class HaltException < Exception

  end


  def self.read_memory(filename)
    return File.read(filename).split(",").map(&:strip).map(&:to_i)
  end

  def initialize(memory)
    @memory = memory
    @pc = 0
    @relative_base = 0
  end

  # the parameter to be interpreted as a position - if the parameter is 50, its value is the value stored at address 50 in memory
  POSITION_MODE = 0
  # in immediate mode, a parameter is interpreted as a value - if the parameter is 50, its value is simply 50
  IMMEDIATE_MODE = 1
  # the parameter is interpreted as a position. Like position mode, parameters in relative mode can be read from or written to.
  RELATIVE_MODE = 2

  def write_address_mode(mode, parameter)
    if mode == POSITION_MODE
      return parameter
    elsif mode == IMMEDIATE_MODE
      raise "Destination parameter in immediate mode"
    elsif mode == RELATIVE_MODE
      return parameter + @relative_base
    else
      raise "Unknown addressing mode"
    end
  end

  def read_address_mode(mode, parameter)
    if mode == POSITION_MODE
      return @memory[parameter]
    elsif mode == IMMEDIATE_MODE
      return parameter
    elsif mode == RELATIVE_MODE
      return @memory[parameter + @relative_base]
    else
      raise "Unknown addressing mode"
    end
  end

  def run(input)

    while @pc < @memory.size

      instruction = @memory[@pc]

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
        param_1 = @memory[@pc + 1]
        param_2 = @memory[@pc + 2]
        param_3 = @memory[@pc + 3]
        @memory[write_address_mode(modes[2], param_3)] = read_address_mode(modes[0], param_1) + read_address_mode(modes[1], param_2)

        @pc += 4
        next
      end

      # Opcode 2 works exactly like opcode 1, except it multiplies the two inputs instead of adding them.
      if opcode == 2
        # Parameters that an instruction writes to will never be in immediate mode.
        param_1 = @memory[@pc + 1]
        param_2 = @memory[@pc + 2]
        param_3 = @memory[@pc + 3]
        @memory[write_address_mode(modes[2], param_3)] = read_address_mode(modes[0], param_1) * read_address_mode(modes[1], param_2)

        @pc += 4
        next
      end

      # Opcode 3 takes a single integer as input and saves it to the position given by its only parameter.
      # For example, the instruction 3,50 would take an input value and store it at address 50.
      if opcode == 3
        raise "Input is empty" if input.nil?

        param_1 = @memory[@pc + 1]
        @memory[write_address_mode(modes[0], param_1)] = input

        @pc += 2
        next
      end

      # Opcode 4 outputs the value of its only parameter.
      # For example, the instruction 4,50 would output the value at address 50.
      if opcode == 4
        param_1 = @memory[@pc + 1]
        output = read_address_mode(modes[0], param_1)

        @pc += 2

        return output
      end

      # Opcode 5 is jump-if-true: if the first parameter is non-zero,
      # it sets the instruction pointer to the value from the second parameter. Otherwise, it does nothing.
      if opcode == 5
        param_1 = @memory[@pc + 1]
        if read_address_mode(modes[0], param_1) != 0
          param_2 = @memory[@pc + 2]
          @pc = read_address_mode(modes[1], param_2)
        else
          @pc += 3
        end

        next
      end

      # Opcode 6 is jump-if-false: if the first parameter is zero, it sets the instruction pointer
      # to the value from the second parameter. Otherwise, it does nothing.
      if opcode == 6
        param_1 = @memory[@pc + 1]
        if read_address_mode(modes[0], param_1) == 0
          param_2 = @memory[@pc + 2]
          @pc = read_address_mode(modes[1], param_2)
        else
          @pc += 3
        end

        next
      end

      # Opcode 7 is less than: if the first parameter is less than the second parameter,
      # it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
      if opcode == 7
        param_1 = @memory[@pc + 1]
        param_2 = @memory[@pc + 2]
        param_3 = @memory[@pc + 3]
        if read_address_mode(modes[0], param_1) < read_address_mode(modes[1], param_2)
          @memory[write_address_mode(modes[2], param_3)] = 1
        else
          @memory[write_address_mode(modes[2], param_3)] = 0
        end

        @pc += 4
        next
      end

      # Opcode 8 is equals: if the first parameter is equal to the second parameter,
      # it stores 1 in the position given by the third parameter. Otherwise, it stores 0.
      if opcode == 8
        param_1 = @memory[@pc + 1]
        param_2 = @memory[@pc + 2]
        param_3 = @memory[@pc + 3]
        if read_address_mode(modes[0], param_1) == read_address_mode(modes[1], param_2)
          @memory[write_address_mode(modes[2], param_3)] = 1
        else
          @memory[write_address_mode(modes[2], param_3)] = 0
        end

        @pc += 4
        next
      end

      # Opcode 9 adjusts the relative base by the value of its only parameter.
      # The relative base increases (or decreases, if the value is negative) by the value of the parameter.
      if opcode == 9
        param_1 = @memory[@pc + 1]
        @relative_base += read_address_mode(modes[0], param_1)
        @pc += 2
        next
      end

      if opcode == 99
        raise HaltException
      end

      raise "Unknown opcode: #{opcode}"
    end

    raise "should have seen opcode 99"
  end

end