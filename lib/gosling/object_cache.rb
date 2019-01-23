require 'fiddle'

class Object
  def unfreeze
    Fiddle::Pointer.new(object_id * 2)[1] &= ~(1 << 3)
  end
end

module ObjectCache
  attr_reader :size

  def clear
    @cache.clear
    @size = 0
  end

  def recycle(obj)
    return if @cache.any? { |x| x.equal?(obj) }
    self.reset(obj)
    obj.freeze
    @cache[@size] = obj
    @size += 1
  end

  def get
    if @size <= 0
      self.create
    else
      @size -= 1
      obj = @cache[@size]
      obj.unfreeze
      obj
    end
  end

  protected

  def create
    raise "Derived classes must implement create()."
  end

  def reset(obj)
    raise "Derived classes must implement reset()."
  end
end
