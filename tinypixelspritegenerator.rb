#!ruby -Ku
# -*- mode: ruby; coding: utf-8 -*-
# Last updated: <2017/04/04 20:52:25 +0900>
#
# tiny pixel sprite generator
#
# original
# zfedoran/pixel-sprite-generator
# https://github.com/zfedoran/pixel-sprite-generator
#
# License : MIT License

# tiny pixel sprite generator
class TinyPixelSpriteGenerator

  # @return [Integer] width
  attr_accessor :width

  # @return [Integer] height
  attr_accessor :height

  # @return [Array<Integer>] pixel data. R,G,B,A * width * height.
  attr_accessor :pixel_data

  # initialize
  # @param maskdata [Array<Array>] mask data.
  #                                 -1 = always border (black).
  #                                 0 = empty.
  #                                 1 = Randomly chosen empty/body.
  #                                 2 = Randomly chosen border/body.
  # @param mirror_x [true, false] mirror x
  # @param mirror_y [true, false] mirror y
  # @param colored [true, false] color on BW
  # @param edgebrightness [Float] edge brightness. default 0.3
  # @param colorvariations [Float] color variations. default 0.2
  # @param brightnessnoise [Float] brightness noise. default 0.3
  # @param saturation [Float] saturation. default 0.5
  # @param seed [Integer] random seed
  def initialize(maskdata,
                 mirror_x: true,
                 mirror_y: true,
                 colored: true,
                 edgebrightness: 0.3,
                 colorvariations: 0.2,
                 brightnessnoise: 0.3,
                 saturation: 0.5,
                 seed: 0
                )
    @mask_data = maskdata
    @mask_height = maskdata.size
    @mask_width = maskdata[0].size
    @mirror_x = mirror_x
    @mirror_y = mirror_y
    @width = @mask_width * ((mirror_x)? 2 : 1)
    @height = @mask_height * ((mirror_y)? 2 : 1)
    @colored = colored
    @edgebrightness = edgebrightness
    @colorvariations = colorvariations
    @brightnessnoise = brightnessnoise
    @saturation = saturation

    srand(seed)

    init_data
    generate_random_sample
    mirror_data_x if @mirror_x
    mirror_data_y if @mirror_y
    generate_edges
    @pixel_data = render_pixel_data
  end

  def init_data
    @data = Array.new(@height).map { Array.new(@width, -1) }

    # apply mask
    @mask_height.times do |y|
      @mask_width.times { |x| @data[y][x] = @mask_data[y][x] }
    end
  end

  def mirror_data_x
    @height.times do |y|
      (@width / 2).times { |x| @data[y][@width - x - 1] = @data[y][x] }
    end
  end

  def mirror_data_y
    (@height / 2).times do |y|
      @width.times { |x| @data[@height - y - 1][x] = @data[y][x] }
    end
  end

  def generate_random_sample
    @height.times do |y|
      @width.times do |x|
        v = @data[y][x]
        if v == 1
          v = v * rand.round
        elsif v == 2
          v = (rand > 0.5)? 1 : -1
        end
        @data[y][x] = v
      end
    end
  end

  def generate_edges
    @height.times do |y|
      @width.times do |x|
        next if @data[y][x] <= 0
        @data[y - 1][x] = -1 if (y - 1 >= 0 and @data[y - 1][x] == 0)
        @data[y + 1][x] = -1 if (y + 1 < @height and @data[y + 1][x] == 0)
        @data[y][x - 1] = -1 if (x - 1 >= 0 and @data[y][x - 1] == 0)
        @data[y][x + 1] = -1 if (x + 1 < @width and @data[y][x + 1] == 0)
      end
    end
  end

  def render_pixel_data
    pixeldata = Array.new(@width * @height * 4, 0)
    is_vertical_gradient = (rand > 0.5)
    saturation = [[(rand * @saturation), 1.0].min, 0.0].max
    hue = rand

    if is_vertical_gradient
      ulen, vlen = @height, @width
    else
      ulen, vlen = @width, @height
    end

    ulen.times do |u|
      newcolor = (((rand * 2 - 1) + (rand * 2 - 1) + (rand * 2 - 1)) / 3).abs
      hue = rand if newcolor > (1.0 - @colorvariations)
      vlen.times do |v|
        if is_vertical_gradient
          value = @data[u][v]
          index = (u * vlen + v) * 4
        else
          value = @data[v][u]
          index = (v * ulen + u) * 4
        end

        rgb = { :r => 1.0, :g => 1.0, :b => 1.0, :a => 1.0 }
        if value == 0
          rgb = { :r => 0.0, :g => 0.0, :b => 0.0, :a => 0.0 }
        else
          if @colored
            brightness = Math.sin((u.to_f / ulen) * Math::PI) *
                         (1.0 - @brightnessnoise) + (rand * @brightnessnoise)
            rgb = hsl_to_rgb(hue, saturation, brightness)
            if value == -1
              rgb[:r] *= @edgebrightness
              rgb[:g] *= @edgebrightness
              rgb[:b] *= @edgebrightness
            end
          else
            if value == -1
              rgb[:r] = 0
              rgb[:g] = 0
              rgb[:b] = 0
            end
          end
        end

        pixeldata[index + 0] = (rgb[:r] * 255).to_i
        pixeldata[index + 1] = (rgb[:g] * 255).to_i
        pixeldata[index + 2] = (rgb[:b] * 255).to_i
        pixeldata[index + 3] = (rgb[:a] * 255).to_i
      end
    end

    i = 0
    pdata = []
    @height.times do |y|
      dt = []
      @width.times do |x|
        r = pixeldata[i + 0]
        g = pixeldata[i + 1]
        b = pixeldata[i + 2]
        a = pixeldata[i + 3]
        dt.push([r, g, b, a])
        i += 4
      end
      pdata.push(dt)
    end

    return pdata
  end

  def hsl_to_rgb(h, s, l)
    rgb = { :r => 0.0, :g => 0.0, :b => 0.0, :a => 1.0 }
    i = (h * 6.0).floor
    f = h * 6.0 - i
    p = l * (1.0 - s)
    q = l * (1.0 - f * s)
    t = l * (1.0 - (1.0 - f) * s)
    case (i % 6)
    when 0 then rgb[:r], rgb[:g], rgb[:b] = l, t, p
    when 1 then rgb[:r], rgb[:g], rgb[:b] = q, l, p
    when 2 then rgb[:r], rgb[:g], rgb[:b] = p, l, t
    when 3 then rgb[:r], rgb[:g], rgb[:b] = p, q, l
    when 4 then rgb[:r], rgb[:g], rgb[:b] = t, p, l
    when 5 then rgb[:r], rgb[:g], rgb[:b] = l, p, q
    end
    return rgb
  end

  # string array to mask array
  # @param str_array [Array<String>] string array
  #                                  "0" or " " = empty
  #                                  "1" or "." = Randomly chosen Empty/Body
  #                                  "2" or "+" = Randomly chosen Border/Body
  #                                  "3" or "*" = Always border (black)
  # @return [Array<Array>] mask array
  def self.convert_mask(str_array)
    result = []
    str_array.each do |s|
      slst = s.split("")
      dt = []
      slst.each do |c|
        dt <<
          case c
          when "0", " " then 0
          when "1", "." then 1
          when "2", "+" then 2
          else -1
          end
      end
      result.push(dt)
    end
    return result
  end
end

if $0 == __FILE__
  # ----------------------------------------
  # usage sample

  require 'dxruby'
  # require 'pp'

  # convert array to DXRuby Image
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

  mask_spaceship = [
    [
      # 0 : 12x12
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
    ],[
      # 1 : 16x16
      '        ',
      '      ..',
      '      .*',
      '     ..*',
      '     ..+',
      '    ...+',
      '   ....*',
      '   ....*',
      '  ....++',
      ' ....+++',
      ' ....+++',
      ' ......*',
      ' ......*',
      ' ......*',
      '    ....',
      '        ',
    ],[
      # 2: 24x24
      '            ',
      '           .',
      '           .',
      '          ..',
      '         ..*',
      '         ..*',
      '      .....*',
      '      .....+',
      '     .....++',
      '     .....++',
      '     .....++',
      '     ......+',
      '     ......*',
      '    .......*',
      '    .......*',
      '   ........*',
      '   .......++',
      '  .......+++',
      '  .......+++',
      ' .........++',
      ' ..........*',
      '     .......',
      '       .....',
      '            ',
    ]
  ]

  # convert mask array
  kind = (ARGV.empty?)? 2 : ARGV[0].to_i
  mask = TinyPixelSpriteGenerator.convert_mask(mask_spaceship[kind])

  # make images
  imgs = []
  96.times do |i|

    # generate pixels array
    p = TinyPixelSpriteGenerator.new(
      mask,
      mirror_x: true,
      mirror_y: false,
      colored: true,
      edgebrightness: 0.3,
      colorvariations: 0.2,
      brightnessnoise: 0.3,
      saturation: 0.5,
      seed: i * 4
    )
    img = array_to_image(p.pixel_data)
    imgs.push(img)
  end

  Window.resize(320, 240)
  Window.bgcolor = [64, 132, 184]
  Window.scale = 3

  # main loop
  Window.loop do
    break if Input.keyPush?(K_ESCAPE)
    x, y = 0, 0
    imgs.each do |img|
      Window.draw(x, y, img)
      x += img.width + 2
      if x + img.width >= Window.width
        x = 0
        y += img.height + 2
      end
    end
  end
end
