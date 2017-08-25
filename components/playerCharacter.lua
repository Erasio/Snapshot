local PlayerCharacter = Component.create("PlayerCharacter")

function PlayerCharacter:initialize()
	self.velocity = Vector(0, 0)
    self.inAir = false
    self.onGround = false
    self.jumps = 0
    self.maxJumps = 1
    self.maxMovementSpeed = 300
    self.movementSpeed = self.maxMovementSpeed
    self.airControl = 0.5
end

return PlayerCharacter