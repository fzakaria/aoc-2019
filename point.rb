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