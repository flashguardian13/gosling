require 'singleton'

require_relative 'object_cache.rb'

class MatrixCache
  include Singleton
  include ObjectCache

  def initialize
    @cache = {}
  end

  protected

  def create
    Snow::Mat3.new
  end

  def reset(matrix)
    type_check(matrix, Snow::Mat3)
    matrix.load_identity
  end
end
