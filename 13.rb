#!/usr/bin/env ruby

require_relative 'int_code'
require_relative 'point'
require 'ruby2d'

module Day13

  class Tile
    attr_accessor :id, :point
    # the id is interpreted as follows
    #0 is an empty tile. No game object appears in this tile.
    #1 is a wall tile. Walls are indestructible barriers.
    #2 is a block tile. Blocks can be broken by the ball.
    #3 is a horizontal paddle tile. The paddle is indestructible.
    #4 is a ball tile. The ball moves diagonally and bounces off objects.

    def initialize(id, point)
      @id = id
      @point = point
    end

  end

  module Part1

    memory = ::IntCode.read_memory("13.txt")
    cpu = ::IntCode.new(memory)

    board = []

    begin

      outputs = []
      while true
        # every three output instructions specify the x position (distance from the left), y position (distance from the top), and tile id.
        output = cpu.run(0)
        outputs << output.to_i

        if outputs.size == 3
          x, y, id =  outputs

          if board.size <= y
            board[y] = []
          end

          board[y][x] = id

          # clear outputs
          outputs.clear
        end
      end
    rescue IntCode::HaltException => e
    end

    puts board.flatten.filter { |id| id == 2 }.count
  end

  module Part2
    extend  Ruby2D::DSL

    # Set the window size
    set width: 450, height: 300

    @memory = ::IntCode.read_memory("13.txt")
    # Memory address 0 represents the number of quarters that have been inserted; set it to 2 to play for free.
    @memory[0] = 2

    @cpu = ::IntCode.new(@memory)

    @board = []

    @score = 0

    @tick = 0

    @start = false

    @text = Text.new("Tick: #{@tick} (#{@tick/60} seconds) Score: #{@score}", x: 50, y: 250)

    @event = nil

    @paddle = nil

    @ball = nil

    def self.update_score
      @text.text = "Tick: #{@tick} (#{@tick/60} seconds) Score: #{@score}"
    end

    # each tick of CPU is really 3
    def self.tick_cpu

      input = 0
      unless @event.nil?
        input = case @event.key
                when "right"
                  1
                when "left"
                  -1
                else
                  0
                end
        @event = nil
      end

      output = []
      3.times do
        output << @cpu.run(input)
      end

      x, y, id =  output

      x = x.to_i
      y = y.to_i
      tile = id.to_i

      # segment display
      if x == -1 && y == 0
        @score = tile
        return
      end

      if @board.size <= x
        @board[x] = []
      end

      #set a default piece
      @board[x][y] =  Square.new(x: x*10, y: y*10, size: 10, color: 'white') if @board[x][y].nil?

      square = @board[x][y]

      case tile
      when 0
        square.color = 'white'
      when 1
        square.color = 'black'
      when 2
        square.color = 'blue'
      when 3
        square.color = 'purple'
        @paddle = square
      when 4
        square.color = 'red'
        @ball = square
      else
        raise "Unknown tile #{tile}"
      end
    end

    # A little hack to speed this up
    # I know the board is 42 x 20
    # so lets draw the board to start
    (42 * 20).times do

      self.tick_cpu

    end

    on :key do |event|
      # All keyboard interaction
      @start = true

      @event = event
    end

    update do
      next unless @start

      if @tick % 1 == 0

        # lets have fake input!
        direction = [-1, [@ball.x - @paddle.x, 1].min].max
        if direction == 1
          @event = Ruby2D::Window::KeyEvent.new("fake", "right")
        elsif direction == -1
          @event =  Ruby2D::Window::KeyEvent.new("fake", "left")
        elsif direction == 0
          @event = nil
        else
          raise "Unknown event"
        end

        self.tick_cpu
      end

      self.update_score
      @tick += 1
    end

    # show the window
    begin
      show
    rescue IntCode::HaltException => e
      puts @score
    end

  end

end