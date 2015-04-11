require 'csv'
require 'RMagick'
include Magick

LAYOUTS_CSV_FILE_NAME = 'layouts_8.csv'
BLOCKS_CSV_FILE_NAME = 'blocks_8.csv'
EXPORT_CSV_FILE_NAME = 'export_8.csv'
FONT_PATH = '/Library/Fonts/ヒラギノ丸ゴ Pro W4.otf'

IMAGE_BACKGROUND_COLOR = 'white'
IMAGE_FILE_NAME = 'image.png'
IMAGE_MARGIN = 30

BOOTH_WIDTH = 13
BOOTH_HEIGHT = 13
BOOTH_FILL = 'white'
BOOTH_STROKE = 'black'
BOOTH_STROKE_WIDTH = 1

SPACE_NO_POINT_SIZE = 9

BLOCK_POINT_SIZE = 18

layouts = CSV.table(LAYOUTS_CSV_FILE_NAME)
blocks = CSV.table(BLOCKS_CSV_FILE_NAME)

image_w = (layouts.map { |x| x[:pos_x] }.max + 1) * BOOTH_WIDTH + BOOTH_STROKE_WIDTH
image_h = (layouts.map { |x| x[:pos_y] }.max + 1) * BOOTH_HEIGHT + BOOTH_STROKE_WIDTH
image = Image.new(image_w, image_h)

image_back_w = image_w + IMAGE_MARGIN * 2
image_back_h = image_h + IMAGE_MARGIN * 2
image_back = Image.new(image_back_w, image_back_h) {
  self.background_color = IMAGE_BACKGROUND_COLOR
}

booths_gc = Draw.new
booths_gc.fill(BOOTH_FILL)
booths_gc.stroke(BOOTH_STROKE)
booths_gc.stroke_width(BOOTH_STROKE_WIDTH)

space_no_gc = Draw.new
# Ruby - RMagickで描画される文字列のサイズを取得する方法 - Qiita
# http://qiita.com/ykpaco_404wm/items/88a5bc55376ed913ffaf
space_no_gc.pointsize(SPACE_NO_POINT_SIZE)
space_no_gc.pointsize = SPACE_NO_POINT_SIZE
space_no_gc.font(FONT_PATH)
space_no_gc.font = FONT_PATH

## Export map data
csv_str = CSV.generate do |csv|
  csv << %w(space_no pos_x pos_y map_pos_x map_pos_y)

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

    csv << [
      layout[:space_no],
      layout[:pos_x],
      layout[:pos_y],
      IMAGE_MARGIN + x1,
      IMAGE_MARGIN + y1
    ]
  end
end

block_gc = Draw.new
block_gc.pointsize(BLOCK_POINT_SIZE)
block_gc.pointsize = BLOCK_POINT_SIZE
block_gc.font(FONT_PATH)
block_gc.font = FONT_PATH

blocks.each do |block|
  ## Draw block name
  block_name = block[:name]
  metrics = block_gc.get_type_metrics(block_name)
  x = block[:pos_x] * BOOTH_WIDTH + (BOOTH_WIDTH * 2 - metrics.width) * 0.5
  y = (block[:pos_y] + 2) * BOOTH_HEIGHT - (BOOTH_HEIGHT * 2 - SPACE_NO_POINT_SIZE) * 0.5
  block_gc.text(x, y, block_name)
end

booths_gc.draw(image)
space_no_gc.draw(image)
block_gc.draw(image)

image_back.composite!(image, CenterGravity, OverCompositeOp)
image_back.write(IMAGE_FILE_NAME)

File.write(EXPORT_CSV_FILE_NAME, csv_str)
