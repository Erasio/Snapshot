--- Box2D plugin for STI
-- @module box2d
-- @author Landon Manning
-- @copyright 2017
-- @license MIT/X11

local utils = require((...):gsub('plugins.box2d', 'utils'))
local lg    = require((...):gsub('plugins.box2d', 'graphics'))

return {
	box2d_LICENSE     = "MIT/X11",
	box2d_URL         = "https://github.com/karai17/Simple-Tiled-Implementation",
	box2d_VERSION     = "2.3.2.6",
	box2d_DESCRIPTION = "Box2D hooks for STI.",

	--- Initialize Box2D physics world.
	-- @param world The Box2D world to add objects to.
	box2d_init = function(map, world)
		assert(love.physics, "To use the Box2D plugin, please enable the love.physics module.")

		local body      = love.physics.newBody(world, map.offsetx, map.offsety)
		local collision = {
			body = body,
		}
		
		local data = {}

		local function addObjectToWorld(objshape, vertices, userdata, object)
			local shape

			if userdata.properties.collidable == true then

				if objshape == "polyline" then
					if #vertices == 4 then
						shape = love.physics.newEdgeShape(unpack(vertices))
					else
						shape = love.physics.newChainShape(false, unpack(vertices))
					end
				else
					shape = love.physics.newPolygonShape(unpack(vertices))
				end

				local fixture = love.physics.newFixture(body, shape)
				fixture:setCategory(2)
				fixture:setMask(1, 3)

				fixture:setUserData({box2d=userdata})

				if userdata.properties.sensor == true then
					fixture:setSensor(true)
				end

				local obj = {
					object  = object,
					shape   = shape,
					fixture = fixture,
				}

				table.insert(collision, obj)
			end
		end

		local function getPolygonVertices(object)
			local vertices = {}
			for _, vertex in ipairs(object.polygon) do
				table.insert(vertices, vertex.x)
				table.insert(vertices, vertex.y)
			end

			return vertices
		end

		local function calculateObjectPosition(object, tile)
			local o = {
				shape   = object.shape,
				x       = (object.dx or object.x) + map.offsetx,
				y       = (object.dy or object.y) + map.offsety,
				w       = object.width,
				h       = object.height,
				polygon = object.polygon or object.polyline or object.ellipse or object.rectangle
			}

			local userdata = {
				object     = o,
				properties = object.properties
			}

			table.insert(data, {x = o.x, y = o.y, properties = userdata.properties, name=object.name, w=o.w, h=o.h})

			if o.shape == "rectangle" then
				o.r       = object.rotation or 0
				local cos = math.cos(math.rad(o.r))
				local sin = math.sin(math.rad(o.r))
				local oy  = 0

				if object.gid then
					local tileset = map.tilesets[map.tiles[object.gid].tileset]
					local lid     = object.gid - tileset.firstgid
					local t       = {}

					-- This fixes a height issue
					 o.y = o.y + map.tiles[object.gid].offset.y
					 oy  = tileset.tileheight

					for _, tt in ipairs(tileset.tiles) do
						if tt.id == lid then
							t = tt
							break
						end
					end

					if t.objectGroup then
						for _, obj in ipairs(t.objectGroup.objects) do
							-- Every object in the tile
							calculateObjectPosition(obj, object)
						end

						return
					else
						o.w = map.tiles[object.gid].width
						o.h = map.tiles[object.gid].height
					end
				end

				o.polygon = {
					{ x=o.x+0,   y=o.y+0   },
					{ x=o.x+o.w, y=o.y+0   },
					{ x=o.x+o.w, y=o.y+o.h },
					{ x=o.x+0,   y=o.y+o.h }
				}

				for _, vertex in ipairs(o.polygon) do
					vertex.x, vertex.y = utils.rotate_vertex(map, vertex, o.x, o.y, cos, sin, oy)
				end

				local vertices = getPolygonVertices(o)
				addObjectToWorld(o.shape, vertices, userdata, tile or object)
			elseif o.shape == "ellipse" then
				if not o.polygon then
					o.polygon = utils.convert_ellipse_to_polygon(o.x, o.y, o.w, o.h)
				end
				local vertices  = getPolygonVertices(o)
				local triangles = love.math.triangulate(vertices)

				for _, triangle in ipairs(triangles) do
					addObjectToWorld(o.shape, triangle, userdata, tile or object)
				end
			elseif o.shape == "polygon" then
				local vertices  = getPolygonVertices(o)
				local triangles = love.math.triangulate(vertices)

				for _, triangle in ipairs(triangles) do
					addObjectToWorld(o.shape, triangle, userdata, tile or object)
				end
			elseif o.shape == "polyline" then
				local vertices = getPolygonVertices(o)
				addObjectToWorld(o.shape, vertices, userdata, tile or object)
			end
		end

		for _, tile in pairs(map.tiles) do
			if map.tileInstances[tile.gid] then
				if tile.properties.collidable then
					for _, instance in ipairs(map.tileInstances[tile.gid]) do
						-- Every object in every instance of a tile
						if tile.objectGroup then
							for _, object in ipairs(tile.objectGroup.objects) do
								if object.properties.collidable == true then
									object.dx = instance.x + object.x
									object.dy = instance.y + object.y
									calculateObjectPosition(object, instance)
								end
							end
						end

						-- Every instance of a tile
						if tile.properties.collidable == true then
							local object = {
								shape      = "rectangle",
								x          = instance.x,
								y          = instance.y,
								width      = map.tilewidth,
								height     = map.tileheight,
								properties = tile.properties
							}

							calculateObjectPosition(object, instance)
						end
					end
				end
			end
		end

		for _, layer in ipairs(map.layers) do
			-- Entire layer
			if layer.properties.collidable == true then
				if layer.type == "tilelayer" then
					for gid, tiles in pairs(map.tileInstances) do
						local tile = map.tiles[gid]
						local tileset = map.tilesets[tile.tileset]

						for _, instance in ipairs(tiles) do
							if instance.layer == layer then
								local object = {
									shape      = "rectangle",
									x          = instance.x,
									y          = instance.y,
									width      = tileset.tilewidth,
									height     = tileset.tileheight,
									properties = tile.properties
								}

								calculateObjectPosition(object, instance)
							end
						end
					end
				elseif layer.type == "objectgroup" then
					for _, object in ipairs(layer.objects) do
						calculateObjectPosition(object)
					end
				elseif layer.type == "imagelayer" then
					local object = {
						shape      = "rectangle",
						x          = layer.x or 0,
						y          = layer.y or 0,
						width      = layer.width,
						height     = layer.height,
						properties = layer.properties
					}

					calculateObjectPosition(object)
				end
			end

			-- Individual objects
			if layer.type == "objectgroup" then
				for _, object in ipairs(layer.objects) do
					if object.properties.collidable == true then
						calculateObjectPosition(object)
					end
				end
			end
		end

		map.box2d_collision = collision
		map.box2d_data = data
	end,


	-- Create new collision (copies) with exactly the size of the screen and repeat on all sides.
	-- @param map 	map object (should be self when calling this!)
	-- @param x 	The x location on the map
	-- @param y 	The y location on the map
	-- @param w 	The width of the snapshot
	-- @param h 	The height of the snapshot
	box2d_createSnapShot = function(map, x, y, w, h)
		local collision = map.box2d_collision
		local bodyX, bodyY = collision.body:getPosition()
		local world = collision.body:getWorld()
		if map.box2d_altCollision then
			for _, slot in pairs(map.box2d_altCollision) do
				if slot.body then
					slot.body:destroy()
				end
			end
		end
		map.box2d_altCollision = {
			{body=love.physics.newBody(world, bodyX, bodyY)},
			{body=love.physics.newBody(world, bodyX + w, bodyY)},
			{body=love.physics.newBody(world, bodyX - w, bodyY)},
			{body=love.physics.newBody(world, bodyX, bodyY + h)},
			{body=love.physics.newBody(world, bodyX, bodyY - h)}
		}
		local altCollision = map.box2d_altCollision
		altCollision.dimensions = {x, y, w, h}

		-- p0 & p1 define the first line segment. 
		-- p2 & p3 define the second line segment. 
		local findIntersection = function(p0, p1, p2, p3)
		    local s02_x, s02_y, s10_x, s10_y, s32_x, s32_y, s_numer, t_numer, denom, t = 0
    		s10_x = p1[1] - p0[1]
			s10_y = p1[2] - p0[2]
			s32_x = p3[1] - p2[1]
			s32_y = p3[2] - p2[2]

			denom = s10_x * s32_y - s32_x * s10_y

			if denom == 0 then
			    return 
			end
			
			local denomPositive = denom > 0

			s02_x = p0[1] - p2[1];
			s02_y = p0[2] - p2[2];
			s_numer = s10_x * s02_y - s10_y * s02_x;
			if (s_numer < 0) == denomPositive then
			    return
			end

			t_numer = s32_x * s02_y - s32_y * s02_x;
			if (t_numer < 0) == denomPositive then
			    return
			end

			if (s_numer > denom) == denomPositive or (t_numer > denom) == denomPositive then
			    return
			end

			t = t_numer / denom;
			local x = p0[1] + (t * s10_x)
			local y = p0[2] + (t * s10_y) 

		    return {x, y}
		end

		-- Distance between two points
		local pointDistance = function(p1, p2)
			return math.sqrt( math.pow(p2[1] - p1[1], 2) + math.pow(p2[2] - p1[2], 2) )
		end

		-- Finds the location between two points intersected by the screen
		-- Returns nil if no intersection has been found
		local getNewPointLocation = function(point, point2)
			if point2 then
				local newPoint = {}
				-- h = horizontal
				-- v = vertical
				local h1 = findIntersection(point, point2, {x, y}, {x + w, y})
				local h2 = findIntersection(point, point2, {x, y + h}, {x + w, y + h})
				local v1 = findIntersection(point, point2, {x, y}, {x, y + h})
				local v2 = findIntersection(point, point2, {x + w, y}, {x + w, y + h})

				-- Check if we collide with two screen edges. Determine closer one (since the other one will be out of picture) and use that one.
				local temp1 = h1 or h2 or v1 or v2
				local temp2 = nil
				if h2 and temp1 ~= h2 then
					temp2 = h2
				elseif v1 and temp1 ~= v1 then
					temp2 = v1
				elseif v2 and temp1 ~= v2 then
					temp2 = v2
				end

				if temp2 then
					if pointDistance(point, temp1) < pointDistance(point, temp2) then
						table.insert(newPoint, temp1[1])
						table.insert(newPoint, temp1[2])
						table.insert(newPoint, temp2[1])
						table.insert(newPoint, temp2[2])
					else
						table.insert(newPoint, temp2[1])
						table.insert(newPoint, temp2[2])
						table.insert(newPoint, temp1[1])
						table.insert(newPoint, temp1[2])						
					end
				elseif temp1 then
					table.insert(newPoint, temp1[1])
					table.insert(newPoint, temp1[2])
				else
					newPoint = nil 
				end

				return newPoint
			end
		end

		for i = #collision, 2, -1 do
			local obj = collision[i]
			local body = obj.fixture:getBody()

			-- Store points in a sensbile way. I don't wanna get insane just accessing point!
			local tempPoints = {obj.shape:getPoints()}
			local oPoints = {}

			for j = 1, #tempPoints, 2 do
				local pointX = tempPoints[j]
				local pointY = tempPoints[j + 1]
				table.insert(oPoints, {pointX, pointY})
			end



			-- Determine if the shape is within the screen and whether or not it is at the edge.
			local complete = true

			for k, point in ipairs(oPoints) do
				if point[1] > x and point[1] < x + w then
					if not (point[2] > y and point[2] < y + h) then
						complete = false
					end
				else
					complete = false
				end
			end

			-- If the shape is completely within the snapshot, just add the duplicates
			if complete then
				local fixture = love.physics.newFixture(altCollision[1].body, obj.shape)
				fixture:setCategory(3)
				fixture:setMask(1, 2)
				fixture:setUserData(obj.fixture:getUserData())
				table.insert(altCollision[1], {shape=obj.shape, fixture=fixture})
				fixture = love.physics.newFixture(altCollision[2].body, obj.shape)
				fixture:setCategory(3)
				fixture:setMask(1, 2)
				fixture:setUserData(obj.fixture:getUserData())
				table.insert(altCollision[2], {shape=obj.shape, fixture=fixture})
				fixture = love.physics.newFixture(altCollision[3].body, obj.shape)
				fixture:setCategory(3)
				fixture:setMask(1, 2)
				fixture:setUserData(obj.fixture:getUserData())
				table.insert(altCollision[3], {shape=obj.shape, fixture=fixture})
				fixture = love.physics.newFixture(altCollision[4].body, obj.shape)
				fixture:setCategory(3)
				fixture:setMask(1, 2)
				fixture:setUserData(obj.fixture:getUserData())
				table.insert(altCollision[4], {shape=obj.shape, fixture=fixture})
				fixture = love.physics.newFixture(altCollision[5].body, obj.shape)
				fixture:setCategory(3)
				fixture:setMask(1, 2)
				fixture:setUserData(obj.fixture:getUserData())
				table.insert(altCollision[5], {shape=obj.shape, fixture=fixture})
			-- If the shape has to be cut into shape (haha)
			else
				local cull = true
				local newVertecies = {}

				for k, point in ipairs(oPoints) do

					-- If point is within the screen dump it in table for later shape creation
					if point[1] >= x and point[1] <= x + w and point[2] >= y and point[2] <= y + h then
						table.insert(newVertecies, point[1])
						table.insert(newVertecies, point[2])
						cull = false
					end
					-- Check if next point intersects and needs to be modified for this shape
					local newPoint = {}

					if oPoints[k+1] then
						newPoint = getNewPointLocation(point, oPoints[k+1])
					else
						newPoint = getNewPointLocation(point, oPoints[1])
					end

					-- If a modified position has been found, add to our list of vertices.
					if newPoint then
						for i=1, #newPoint, 2 do
							table.insert(newVertecies, newPoint[i])
							table.insert(newVertecies, newPoint[i+1])
							cull = false
						end
					-- If no modified position has been found, check if the closest corner is within the shape.
					-- If it is, add the corner to the shape
					else
						-- Determine closest corner
						local edgePoint1 = {x, y}
						local edgePoint2 = {x + w, y}
						local edgePoint3 = {x, y + h}
						local edgePoint4 = {x + w, y + h}
						local distance1 = pointDistance(point, edgePoint1)
						local distance2 = pointDistance(point, edgePoint2)
						local distance3 = pointDistance(point, edgePoint3)
						local distance4 = pointDistance(point, edgePoint4)
						local edgePoint

						if distance1 <= distance2 and distance1 <= distance3 and distance1 <= distance4 then
							edgePoint = edgePoint1
						elseif distance2 <= distance3 and distance2 <= distance4 then
							edgePoint = edgePoint2
						elseif distance3 <= distance4 then
							edgePoint = edgePoint3
						else
							edgePoint = edgePoint4
						end

						-- If it's not a duplicate, add it to our list of vertices.
						if newVertecies[#newVertecies - 1] ~= edgePoint[1] or newVertecies[#newVertecies] ~= edgePoint[2] then
							if obj.shape:testPoint(body:getX(), body:getY(), 0, edgePoint[1], edgePoint[2]) then
								table.insert(newVertecies, edgePoint[1])
								table.insert(newVertecies, edgePoint[2])
							end
						end
					end
				end

				-- If there are any vertices to consider
				-- create shape based on those new vertices
				if newVertecies then
					if not cull then
						
						-- If we have a valid number of points (aka not just a point)
						if #newVertecies > 2 then
							local shape = {}

							-- Special treatment for different amounts of vertices for performance reasons
							if #newVertecies == 4 then
								shape = love.physics.newEdgeShape(unpack(newVertecies))
							else
								shape = love.physics.newChainShape(true, unpack(newVertecies))
							end

							-- Add the shape to our 5 bodies
							local fixture = love.physics.newFixture(altCollision[1].body, shape)
							fixture:setCategory(3)
							fixture:setMask(1, 2)
							fixture:setUserData(obj.fixture:getUserData())
							table.insert(altCollision[1], {shape=shape, fixture=fixture})
							fixture = love.physics.newFixture(altCollision[2].body, shape)
							fixture:setCategory(3)
							fixture:setMask(1, 2)
							fixture:setUserData(obj.fixture:getUserData())
							table.insert(altCollision[2], {shape=shape, fixture=fixture})
							fixture = love.physics.newFixture(altCollision[3].body, shape)
							fixture:setCategory(3)
							fixture:setMask(1, 2)
							fixture:setUserData(obj.fixture:getUserData())
							table.insert(altCollision[3], {shape=shape, fixture=fixture})
							fixture = love.physics.newFixture(altCollision[4].body, shape)
							fixture:setCategory(3)
							fixture:setMask(1, 2)
							fixture:setUserData(obj.fixture:getUserData())
							table.insert(altCollision[4], {shape=shape, fixture=fixture})
							fixture = love.physics.newFixture(altCollision[5].body, shape)
							fixture:setCategory(3)
							fixture:setMask(1, 2)
							fixture:setUserData(obj.fixture:getUserData())
							table.insert(altCollision[5], {shape=shape, fixture=fixture})
						end
					end
				end
			end
		end
	end,

	box2d_destroySnapshot = function(map)
		local altCollision = map.box2d_altCollision
		for _, slot in pairs(altCollision) do
			if type(slot) == "table" then
				if slot.body then
					for k, v in ipairs(slot) do
						if type(v) == "table" then
							v.fixture:destroy()
						end
					end
				end
				if slot.body then
					slot.body:destroy()
				end
			end
		end
		map.box2d_altCollision = nil
	end,

	--- Draw Box2D physics world.
	-- @param tx Translate on X
	-- @param ty Translate on Y
	-- @param sx Scale on X
	-- @param sy Scale on Y
	box2d_draw = function(map, tx, ty, sx, sy)
		local collision = map.box2d_collision

		lg.push()
		lg.scale(sx or 1, sy or sx or 1)
		lg.translate(math.floor(tx or 0), math.floor(ty or 0))

		--if map.mode == "snapshot" then
		if map.box2d_altCollision then
			for _, slot in pairs(map.box2d_altCollision) do
				if slot.body then
					for _, obj in ipairs(slot) do
						if _ ~= dimensions then
							local points = {slot.body:getWorldPoints(obj.shape:getPoints())}
							local shape_type = obj.shape:getType()

							if shape_type == "edge" or shape_type == "chain" then
								love.graphics.line(points)
							elseif shape_type == "polygon" then
								love.graphics.polygon("line", points)
							else
								error("sti box2d plugin does not support "..shape_type.." shapes")
							end
						end
					end
				end
			end
		else
			for _, obj in ipairs(collision) do
				local points = {collision.body:getWorldPoints(obj.shape:getPoints())}
				local shape_type = obj.shape:getType()

				if shape_type == "edge" or shape_type == "chain" then
					love.graphics.line(points)
				elseif shape_type == "polygon" then
					love.graphics.polygon("line", points)
				else
					error("sti box2d plugin does not support "..shape_type.." shapes")
				end
			end
		end

		lg.pop()
	end,
}

--- Custom Properties in Tiled are used to tell this plugin what to do.
-- @table Properties
-- @field collidable set to true, can be used on any Layer, Tile, or Object
-- @field sensor set to true, can be used on any Tile or Object that is also collidable
