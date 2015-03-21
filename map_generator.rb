require 'csv'
require 'RMagick'
include Magick

LAYOUTS_CSV_FILE_NAME = 'layouts.csv'
BLOCKS_CSV_FILE_NAME = 'blocks.csv'
IMAGE_WIDTH = 1270
IMAGE_HEIGHT = 540
IMAGE_BACKGROUND_COLOR = 'white'
IMAGE_FILE_NAME = 'image.png'

layouts = CSV.table(LAYOUTS_CSV_FILE_NAME)
blocks = CSV.table(BLOCKS_CSV_FILE_NAME)

image = Image.new(IMAGE_WIDTH, IMAGE_HEIGHT) {
  self.background_color = IMAGE_BACKGROUND_COLOR
}

gc = Draw.new
gc.fill('white')
gc.stroke('black')

layout_max_x = layouts.max_by { |layout| layout[:pos_x] }[:pos_x]
layout_max_y = layouts.max_by { |layout| layout[:pos_y] }[:pos_y]
booth_w = IMAGE_WIDTH / layout_max_x
booth_h = IMAGE_HEIGHT / layout_max_y
layouts.each do |layout|
  x1 = layout[:pos_x] * booth_w
  y1 = layout[:pos_y] * booth_h
  x2 = x1 + booth_w
  y2 = y1 + booth_h
  gc.rectangle(x1, y1, x2, y2)
end
gc.draw(image)

layouts.each do |layout|
  w = booth_w
  h = booth_h
  x = layout[:pos_x] * booth_w
  y = layout[:pos_y] * booth_h
  gc.annotate(image, w, h, x, y, layout[:space_no].to_s) do
    self.gravity = CenterGravity
    self.pointsize = 10
  end
end

image.write(IMAGE_FILE_NAME)
