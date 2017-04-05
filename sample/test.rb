#!ruby -Ku
# -*- mode: ruby; coding: utf-8 -*-
# Last updated: <2017/04/06 08:04:52 +0900>
#
# test

require 'pp'
require_relative '../tinypixelspritegenerator'

# ----------------------------------------
# generate pixelart "spaceship". 12 x 12 dot
psg = TinyPixelSpriteGenerator.new("spaceship")
p psg.pixel_data
puts

# ----------------------------------------
# generate pixelart "dragon". 12 x 12 dot
psg = TinyPixelSpriteGenerator.new("dragon")
p psg.pixel_data
puts

# ----------------------------------------
# generate pixelart "robot". 8 x 11 dot.
psg = TinyPixelSpriteGenerator.new("robot")
p psg.pixel_data
puts

# ----------------------------------------
# generate pixelart with custom mask pattern
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

psg = TinyPixelSpriteGenerator.new(
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
p psg.pixel_data

# ----------------------------------------
# generate pixelart "spaceship". 12 x 12 dot -> 24 x 24 dot
psg = TinyPixelSpriteGenerator.new("spaceship", scale_x: 2, scale_y: 2)
p psg.pixel_data
puts
