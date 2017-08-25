local World = Component.create("World")

function World:initialize(world)
	self.maps = {}
	self.mapLocations = {}
	self.mode = "normal"
	self.timeInMode = 0
	self.desiredMode = self.mode
	self.world = world
end

function World:toggleMode()
	if self.desiredMode == "normal" then
		self.desiredMode = "snapshot"
	else
		self.desiredMode = "normal"
	end
end

function World:addCustomObject(obj, entity, objList)
	if not obj.entity then

		if obj.properties.playerStart then
			local player = spawnPlayer(self.world, obj.x, obj.y)
			entity:get("Camera"):setTarget(player)
			entity:get("Camera").vec = Vector(obj.x, obj.y)
			obj.entity = player
		elseif obj.properties.box then
			obj.entity = spawnBox(self.world, obj.x, obj.y, obj.w, obj.h)
		elseif obj.properties.door then
			obj.entity = spawnDoor(self.world, obj.x, obj.y, obj.w, obj.h)
		elseif obj.properties.button then
			local targetName = obj.properties.target
			if targetName then
				local target
				
				for _, v in pairs(objList) do
					if v.name == targetName then
						if not v.entity then
							self:addCustomObject(v, entity, objList)
						end
						target = v.entity
					end
				end
				if target then
					obj.entity = spawnButton(self.world, obj.x, obj.y, obj.w, obj.h, target)
				end
			end
		end
		if obj.entity then
			if obj.properties.sensor then
				obj.entity:get("Physics").fixture:setSensor(true)
			end
		end
	end
end

function World:addMap(name, filepath, x, y, entity)
	-- Remove map with the same name
	self:removeMap(name)

	-- Create new map
	self.maps[name] = Sti(filepath, {"box2d"})
	self.maps[name]:box2d_init(self.world)

	-- Read out custom object data
	for _, obj in pairs(self.maps[name].box2d_data) do
		self:addCustomObject(obj, entity, self.maps[name].box2d_data)
	end

	-- Store map by coordinates (for level streaming)
	if not self.mapLocations[x] then
		self.mapLocations[x] = {}
	end
		-- Remove map at this location
		if self.mapLocations[x][y] then
			self:removeMap(self.mapLocations[x][y])
		end
	self.mapLocations[x][y] = name
end

function World:removeMap(name)
	if self.maps[name] then
		self.maps[name].box2d_collision.body:destroy()
		self.maps[name].box2d_altCollision.body:destroy()
		self.maps[name] = nil
	end
end

return World