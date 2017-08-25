io.stdout:setvbuf("no")

function love.load()
    -- Loading all required libraries and setting up globals
	Vector = require "lib.hump.vector"
    Sti = require "lib.sti"
    lovetoys = require "lib.lovetoys.lovetoys"
    lovetoys.initialize({
        globals = true,
        debug = true
    })
    Maps = require "maps.load"
    require "spawnUtils"

    -- Load components
    Activatable = require "components.logic.activatable"
    Physics = require "components.physics.physics"
    Position = require "components.physics.position"
    Wrappable = require "components.physics.wrappable"
    Button = require "components.physics.button"
    Camera = require "components.rendering.camera"
    World = require "components.rendering.world"
    RenderData = require "components.rendering.renderData"
    CollisionRender = require "components.rendering.collisionRender"
    PlayerCharacter = require "components.playerCharacter"

    -- Load systems
    PlayerInputSystem = require("systems.input.PlayerInputSystem")
    PhysicsPositionSyncSystem = require("systems.logic.PhysicsPositionSyncSystem")
    PlayerUpdateSystem = require("systems.logic.PlayerUpdateSystem")
    WrapSystem = require("systems.logic.WrapSystem")
    WorldUpdateSystem = require("systems.logic.worldUpdateSystem")
    ObjectEventSystem = require("systems.logic.objectEventSystem")
    ButtonSystem = require("systems.logic.buttonSystem")
    ActivatableSystem = require("systems.logic.activatableSystem")
    RenderingSystem = require("systems.rendering.renderingSystem")
    WorldDrawSystem = require("systems.rendering.worldDrawSystem")


    -- Load events
    require "events.keyEvent"
    require "events.collisionEvent"
    require "events.objectEvent"

    world = love.physics.newWorld(0, 10 * 32)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    love.physics.setMeter(32)

    eventManager = EventManager()

    playerInputSystem = PlayerInputSystem()
    objectEventSystem = ObjectEventSystem()

    -- Creating core engine object  
    gameEngine = Engine()
    gameEngine:addSystem(PhysicsPositionSyncSystem())
    gameEngine:addSystem(playerInputSystem)
    gameEngine:addSystem(PlayerUpdateSystem())
    gameEngine:addSystem(WrapSystem())
    gameEngine:addSystem(WorldUpdateSystem())
    gameEngine:addSystem(objectEventSystem)
    gameEngine:addSystem(ButtonSystem())
    gameEngine:addSystem(ActivatableSystem())

    gameEngine:addSystem(WorldDrawSystem())
    gameEngine:addSystem(RenderingSystem())

    eventManager:addListener("KeyEvent", playerInputSystem, PlayerInputSystem.fireEvent)
    eventManager:addListener("ObjectEvent", objectEventSystem, ObjectEventSystem.fireEvent)
    --eventManager:addListener("CollisionEvent", WrapSystem, WrapSystem.physicsReplication)

    dWorld = spawnWorld()
    round = function(num, numDecimalPlaces)
        local mult = 10^(numDecimalPlaces or 0)
        return math.floor(num * mult + 0.5) / mult
    end
end

function beginContact(a, b, coll)
    eventManager:fireEvent(CollisionEvent("beginContact", a, b, coll))
end

function endContact(a, b, coll)
    eventManager:fireEvent(CollisionEvent("endContact", a, b, coll))
end

function preSolve(a, b, coll)
    eventManager:fireEvent(CollisionEvent("preSolve", a, b, coll))
end

function postSolve(a, b, coll, niX, tiX, niY, tiY)
    eventManager:fireEvent(CollisionEvent("postSolve", a, b, coll, niX, tiX, niY, tiY))
end


function love.update(dt)
    world:update(dt)
    gameEngine:update(dt)
end

function love.draw()
    gameEngine:draw()
    love.graphics.print(tostring(love.timer.getFPS()), 50, 30)
    love.graphics.print(tostring(round(love.mouse.getX() + worldCamera.vec.x - worldCamera.dimension.x / 2)) .. " " .. tostring(round(love.mouse.getY() + worldCamera.vec.y - worldCamera.dimension.y / 2)), 50, 40)
    love.graphics.print(tostring(round(player:get("Physics").body:getX())) .. " " .. tostring(round(player:get("Physics").body:getY())), 50, 50)
end

function love.keypressed(key, scancode, isrepeat)
    eventManager:fireEvent(KeyEvent(key, scancode, isrepeat, "pressed"))
end

function love.keyreleased(key, scancode)
    eventManager:fireEvent(KeyEvent(key, scancode, nil, "released"))
end

function love.quit()
	-- When the game closes
end


function table.inspect(t, recursive, intendation, tables)
    intendation = intendation or ""
    recursive = recursive or false
    tables = tables or {}
    if type(t) == "table" then
        local scan = true
        for k, v in pairs(tables) do
            if v == t then
                scan = false 
            end
        end
        if scan then
            table.insert(tables, t)
            for k, v in pairs(t) do
                if recursive then
                    print(intendation .. tostring(k) .. ":")
                    table.inspect(v, recursive, intendation .. "\t", tables)
                else
                    print(intendation .. tostring(k) .. ": table")
                end
            end
        end
    else
        print(intendation .. tostring(t))
    end
end--]]