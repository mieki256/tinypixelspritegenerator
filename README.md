tinypixelspritegenerator
========================

ドット絵を自動生成するRubyスクリプト

Description
-----------

[zfedoran/pixel-sprite-generator](https://github.com/zfedoran/pixel-sprite-generator) を Ruby で移植。

Screenshot
----------

DXRuby を使ってテスト表示。3倍に拡大表示。

![all type](./screenshot/all_type.png)

Requirement
-----------

Ruby 2.2以上。

Usage
-----

### generate pixelart "spaceship". 12 x 12 dot

    require_relative 'tinypixelspritegenerator'
    psg = TinyPixelSpriteGenerator.new("spaceship", seed: 43291)
    p psg.pixel_data

### generate pixelart "dragon". 12 x 12 dot

    require_relative 'tinypixelspritegenerator'
    psg = TinyPixelSpriteGenerator.new("dragon", seed: 29080)
    p psg.pixel_data

### generate pixelart "robot". 8 x 11 dot.

    require_relative 'tinypixelspritegenerator'
    psg = TinyPixelSpriteGenerator.new("robot", seed: 57343)
    p psg.pixel_data

### generate pixelart with custom mask pattern

    require_relative 'tinypixelspritegenerator'
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

### generate pixelart "spaceship". 12 x 12 dot -> 24 x 24 dot

    require_relative 'tinypixelspritegenerator'
    psg = TinyPixelSpriteGenerator.new("spaceship", scale_x: 2, scale_y: 2, seed: 10507)
    p psg.pixel_data

Licence
-------

MIT License

(JavaScript で書かれたオリジナル版が MIT License だったので合わせておきます。)

Author
------

mieki256

original by [zfedoran](https://github.com/zfedoran)
