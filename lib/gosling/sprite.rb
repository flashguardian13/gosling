require_relative 'rect.rb'

module Gosling
  ##
  # This type of Actor accepts a Gosu::Image to be rendered in place of the standard flat-colored shape. It behaves very
  # much like a Rect, except its width and height are automatically set to the width and height of the image given to it
  # and cannot be modified otherwise. The image can be changed at runtime. Changing this actor's color or alpha
  # applies tinting and transparency to the image rendered.
  #
  class Sprite < Rect
    def initialize(window)
      super(window)
      @image = nil
      @color = Gosu::Color.rgba(255, 255, 255, 255)
    end

    ##
    # Returns the image currently assigned to this Sprite.
    #
    def get_image
      @image
    end

    ##
    # Assigns the image to this Sprite, setting its width and height to match the image's.
    #
    def set_image(image)
      raise ArgumentError.new("Expected Image, but received #{image.inspect}!") unless image.is_a?(Gosu::Image)
      @image = image
      self.width = @image.width
      self.height = @image.height
    end

    private

    def render(matrix)
      # TODO: optimize and refactor
      global_vertices = @vertices.map { |v| Transformable.transform_point(matrix, v, Snow::Vec3.new) }
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
