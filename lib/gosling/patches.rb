require 'snow-math'

module Snow
  class Mat3
    def multiply(rhs, out = nil)
      case rhs
      when ::Snow::Mat3
        multiply_mat3(rhs, out)
      when ::Snow::Vec3
        values = (0..2).map { |i| get_row3(i) ** rhs }
        out ||= Snow::Vec3.new
        out.set(values)
      when Numeric
        scale(rhs, rhs, rhs, out)
      else
        raise TypeError, "Invalid type for RHS"
      end
    end
    alias_method :*, :multiply

    def multiply!(rhs)
      multiply rhs, case rhs
                    when ::Snow::Mat3, Numeric then self
                    when ::Snow::Vec3 then rhs
                    else raise TypeError, "Invalid type for RHS"
                    end
    end

    def identity?
      [1, 2, 3, 5, 6, 7].all? { |i| self[i] == 0 } && [0, 4, 8].all? { |i| self[i] == 1 }
    end
  end
end
