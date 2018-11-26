class GamePiece
  attr_accessor :velocity, :layer, :actor

  def initialize
    @velocity = Snow::Vec3[0, 0, 0]
    @layer = nil
    @actor = nil
  end
end