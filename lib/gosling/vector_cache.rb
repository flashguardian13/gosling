require_relative 'object_cache.rb'

class VectorCache
  include Singleton
  include ObjectCache

  def initialize
    @cache = []
  end

  protected

  def create
    Snow::Vec3.new
  end

  def reset(vector)
    type_check(vector, Snow::Vec3)
    vector.set(0, 0, 0)
  end
end
