CollisionEvent = class("CollisionEvent")

function CollisionEvent:initialize(type, a, b, coll, normalImpulse, tangentImpulse)
	self.type = type
	self.a = a
	self.b = b 
	self.coll = coll
end