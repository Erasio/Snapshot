local Button = Component.create("Button")

function Button:initialize(target)
    self.target = target
    self.active = false
end

function Button:setActive(bool)
	self.active = bool
	if self.target then
		eventManager:fireEvent(ObjectEvent(self.target, "active", bool))
	end
end

return Button