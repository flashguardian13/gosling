def type_check(obj, type)
  raise ArgumentError.new("Expected #{type}, but received #{obj.inspect}!") unless obj.is_a?(type)
end

def types_check(obj, *types)
  raise ArgumentError.new("Expected one of #{types.inspect}, but received #{obj.inspect}!") unless types.any? { |type| obj.is_a?(type) }
end

def boolean_check(obj)
  raise ArgumentError.new("Expected true or false, but received #{obj.inspect}!") unless [true, false].include?(obj)
end
