require 'fiddle'

class Object
  FIDDLE_FREEZE_BIT = ~(1 << 3)

  def unfreeze
    ptr = @fiddle_pointer || Fiddle::Pointer.new(object_id * 2)
    ptr[1] &= FIDDLE_FREEZE_BIT
    @fiddle_pointer = ptr
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
