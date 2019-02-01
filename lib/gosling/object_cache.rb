require 'fiddle'

class Object
  def unfreeze
    Fiddle::Pointer.new(object_id * 2)[1] &= ~(1 << 3)
  end
end

module ObjectCache
  def clear
    @cache.clear
  end

  def recycle(obj)
    return if @cache.key?(obj.object_id)
    self.reset(obj)
    obj.freeze
    @cache[obj.object_id] = obj
  end

  def get
    if @cache.empty?
      self.create
    else
      obj = @cache.delete(@cache.keys.first)
      obj.unfreeze
      obj
    end
  end

  def size
    @cache.size
  end

  protected

  def create
    raise "Derived classes must implement create()."
  end

  def reset(obj)
    raise "Derived classes must implement reset()."
  end
end
