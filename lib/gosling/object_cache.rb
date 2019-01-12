module ObjectCache
  def clear
    @cache.clear
  end

  def recycle(obj)
    self.reset(obj)
    @cache.push(obj)
  end

  def get
    if @cache.empty?
      self.create
    else
      @cache.pop
    end
  end

  def size
    @cache.length
  end

  protected

  def create
    raise "Derived classes must implement create()."
  end

  def reset(obj)
    raise "Derived classes must implement reset()."
  end
end
