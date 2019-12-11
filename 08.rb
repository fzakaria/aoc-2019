#!/usr/bin/env ruby

module Day08

  module Part1

    # The image you received is 25 pixels wide and 6 pixels tall.
    width = 25
    height = 6
    layer_size = width * height

    IMAGE = File.read("08.txt").split("").map(&:to_i)

    min_layer = IMAGE.each_slice(layer_size).map.with_index { |layer, index|
      {:index => index, :count => layer.count(0), :layer => layer}
    }.min { |a, b| a[:count] <=> b[:count] }[:layer]

    puts min_layer.count(1) * min_layer.count(2)

  end

  module Part2
    # The image you received is 25 pixels wide and 6 pixels tall.
    width = 25
    height = 6
    layer_size = width * height

    black = 0
    white = 1
    transparent = 2

    IMAGE = File.read("08.txt").split("").map(&:to_i)

    layers = IMAGE.each_slice(layer_size)

    final_layer = []
    #if we go in reverse, then the first non-transparent is the color chosen
    layer_size.times do |index|
      layers.each { |layer|

        next if layer[index] == transparent

        final_layer[index] = layer[index]
        break
      }
    end

    rows = final_layer.each_slice(width).to_a
    rows.each do |row|
      puts row.join(" ")
    end

  end

end
