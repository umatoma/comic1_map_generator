require 'csv'
require 'RMagick'
include Magick

LAYOUTS_CSV_FILE_NAME = 'layouts.csv'
BLOCKS_CSV_FILE_NAME = 'blocks.csv'
IMAGE_BACKGROUND_COLOR = 'white'
IMAGE_FILE_NAME = 'image.png'

BOOTH_WIDTH = 13
BOOTH_HEIGHT = 13
BOOTH_FILL = 'white'
BOOTH_STROKE = 'black'

SPACE_NO_POINT_SIZE = 9

layouts = CSV.table(LAYOUTS_CSV_FILE_NAME)
blocks = CSV.table(BLOCKS_CSV_FILE_NAME)

image_w = (layouts.map { |x| x[:pos_x] }.max + 1) * BOOTH_WIDTH
image_h = (layouts.map { |x| x[:pos_y] }.max + 1) * BOOTH_HEIGHT
image = Image.new(image_w, image_h) {
  self.background_color = IMAGE_BACKGROUND_COLOR
}

booths_gc = Draw.new
booths_gc.fill(BOOTH_FILL)
booths_gc.stroke(BOOTH_STROKE)

space_no_gc = Draw.new
# Ruby - RMagickで描画される文字列のサイズを取得する方法 - Qiita
# http://qiita.com/ykpaco_404wm/items/88a5bc55376ed913ffaf
space_no_gc.pointsize(SPACE_NO_POINT_SIZE)
space_no_gc.pointsize = SPACE_NO_POINT_SIZE

layouts.each do |layout|
  ## Draw circle booth frame
  x1 = layout[:pos_x] * BOOTH_WIDTH
  y1 = layout[:pos_y] * BOOTH_HEIGHT
  x2 = x1 + BOOTH_WIDTH
  y2 = y1 + BOOTH_HEIGHT
  booths_gc.rectangle(x1, y1, x2, y2)

  ## Draw circle booth space number
  space_no = layout[:space_no].to_s
  metrics = space_no_gc.get_type_metrics(space_no)
  x = x1 + (BOOTH_WIDTH - metrics.width) * 0.5
  y = y2 - (BOOTH_HEIGHT - SPACE_NO_POINT_SIZE) * 0.5
  space_no_gc.text(x, y, space_no)
end

booths_gc.draw(image)
space_no_gc.draw(image)

image.write(IMAGE_FILE_NAME)
