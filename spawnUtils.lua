spawnWorld = function()
    local worldEntity = Entity()
    local worldComponent = World(world)
    worldEntity:add(worldComponent)
    worldCamera = Camera(0, 0, 1, 0)
    worldEntity:add(worldCamera)

    worldComponent:addMap("start", "maps/demo.lua", 0, 0, worldEntity)
    gameEngine:addEntity(worldEntity)

    return worldEntity
end

spawnPlayer = function(world, x, y)
	player = Entity()
    local body = love.physics.newBody(world, x, y, "dynamic")
    local shape = love.physics.newCircleShape(32)
    --body:setFixedRotation(true)
    player:add(Physics(body, shape, player))
    player:add(Position(x, y))
    player:add(PlayerCharacter())
    player:add(Wrappable(body, shape, worldCamera.dimension.x, worldCamera.dimension.y, player))
    player:add(RenderData({0, 255, 0}))
    player:add(CollisionRender())

	gameEngine:addEntity(player)

    return player
end

spawnBox = function(world, x, y, w, h)
	local box = Entity()
	local body = love.physics.newBody(world, x, y, "dynamic")
	local shape = love.physics.newPolygonShape(0, 0, 0, h, w, h, w, 0)
	box:add(Position(x, y))
	box:add(Physics(body, shape, box, 0.9))
	box:add(Wrappable(body, shape, worldCamera.dimension.x, worldCamera.dimension.y, box))
	box:add(RenderData({0, 0, 255}))
	box:add(CollisionRender())


	gameEngine:addEntity(box)

	return player
end

spawnButton = function(world, x, y, w, h, target)
	local button = Entity()
	local body = love.physics.newBody(world, x, y, "static")
	local shape = love.physics.newPolygonShape(0, 0, 0, h, w, h, w, 0)
	button:add(Position(x, y))
	button:add(Physics(body, shape, button))
	button:add(Button(target))
	button:add(Wrappable(body, shape, worldCamera.dimension.x, worldCamera.dimension.y, button))
	button:add(RenderData({0, 255, 255}))
	button:add(CollisionRender())

	gameEngine:addEntity(button)

	return button
end

spawnDoor = function(world, x, y, w, h)
	local door = Entity()
	local body = love.physics.newBody(world, x, y, "static")
	local shape = love.physics.newChainShape("true", 0, 0, 0, h, w, h, w, 0)
	door:add(Position(x, y))
	door:add(Physics(body, shape, door))
	door:add(Activatable("removeCollision"))
	door:add(Wrappable(body, shape, worldCamera.dimension.x, worldCamera.dimension.y, door))
	door:add(RenderData({170, 170, 170}))
	door:add(CollisionRender())

	gameEngine:addEntity(door)

	return door
end
