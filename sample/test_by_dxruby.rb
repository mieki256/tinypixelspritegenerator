#!ruby -Ku
# -*- mode: ruby; coding: utf-8 -*-
# Last updated: <2017/04/06 00:03:32 +0900>
#
# test draw by DXRuby

require 'dxruby'
require_relative '../tinypixelspritegenerator'

# array to DXRuby Image
# @param a [Array<Array>] three-dimensional array
def array_to_image(a)
  h = a.size
  w = a[0].size
  img = Image.new(w, h, [0, 0, 0, 0])
  a.each_with_index do |row, y|
    row.each_with_index do |rgb, x|
      r, g, b, a = rgb
      img[x, y] = [a, r, g, b]
    end
  end
  return img
end

mask = [
  # 12x12
  # "0" or " " = empty
  # "1" or "." = Randomly chosen Empty/Body
  # "2" or "+" = Randomly chosen Border/Body
  # "3" or "*" = Always border (black)
  '000000',
  '000011',
  '000013',
  '000113',
  '000113',
  '001113',
  '011122',
  '011122',
  '011122',
  '011113',
  '000111',
  '000000',
]

# generate pixelart
p = TinyPixelSpriteGenerator.new(
  mask,
  mirror_x: true,
  mirror_y: false,
  colored: true,
  edgebrightness: 0.3,
  colorvariations: 0.2,
  brightnessnoise: 0.3,
  saturation: 0.5,
  seed: rand(65536)
)
img = array_to_image(p.pixel_data)

Window.resize(240, 180)
Window.bgcolor = [64, 132, 184]
Window.scale = 3

Window.loop do
  break if Input.keyPush?(K_ESCAPE)
  Window.draw(0, 0, img)
end
