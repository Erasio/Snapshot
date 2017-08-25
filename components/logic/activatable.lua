local Activatable = Component.create("Activatable")

function Activatable:initialize(effect)
	self.effect = effect
	self.active = false
	self.activeUpdated = false
	self.timeSinceActivation = 0
end

function Activatable:activate()
	self.active = true
	self.activeUpdated = false
	self.timeSinceActivation = 0
end

function Activatable:deactivate()
	self.active = false
	self.activeUpdated = false
	self.timeSinceActivation = 0
end

return Activatable