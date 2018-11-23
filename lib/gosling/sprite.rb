require_relative 'rect.rb'

module Gosling
  class Sprite < Rect
    def initialize(window)
      super(window)
      @image = nil
      @color = Gosu::Color.rgba(255, 255, 255, 255)
    end

    def get_image
      @image
    end

    def set_image(image)
      raise ArgumentError.new("Expected Image, but received #{image.inspect}!") unless image.is_a?(Gosu::Image)
      @image = image
      self.width = @image.width
      self.height = @image.height
    end

    private

    def render(matrix)
      global_vertices = @vertices.map { |v| Transform.transform_point(matrix, v) }
      @image.draw_as_quad(
        global_vertices[0][0].to_f, global_vertices[0][1].to_f, @color,
        global_vertices[1][0].to_f, global_vertices[1][1].to_f, @color,
        global_vertices[2][0].to_f, global_vertices[2][1].to_f, @color,
        global_vertices[3][0].to_f, global_vertices[3][1].to_f, @color,
        0
      )
    end

    private :'width=', :'height='
  end
end
