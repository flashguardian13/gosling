module ObjectCache
  attr_reader :size

  def clear
    @cache.clear
    @size = 0
  end

  def recycle(obj)
    return if @cache.any? { |x| x.equal?(obj) }
    self.reset(obj)
    @cache[@size] = obj
    @size += 1
  end

  def get
    if @size <= 0
      self.create
    else
      @size -= 1
      @cache[@size]
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
