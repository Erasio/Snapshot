KeyEvent = class("KeyEvent")

function KeyEvent:initialize(key, scancode, isrepeat, mode)
	self.key = key
	self.scancode = scancode
	self.isrepeat = isrepeat
	self.mode = mode
end