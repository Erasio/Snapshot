ObjectEvent = class("ObjectEvent")

function ObjectEvent:initialize(target, name, ...)
	self.target = target
	self.name = name
	self.params = {...}
end