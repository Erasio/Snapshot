local PlayerUpdateSystem = class("PlayerUpdateSystem", System)

function PlayerUpdateSystem:update(dt)
    local world
    local camera 
    for _, tWorld in pairs(self.targets.world) do
        world = tWorld:get("World")
        camera = tWorld:get("Camera")
    end
    for _, player in pairs(self.targets.player) do
        local physics = player:get("Physics")
        local pc = player:get("PlayerCharacter")
        local contacts = physics.body:getContactList()

        if #contacts > 0 then
            pc.inAir = false 
            for k, contact in pairs(contacts) do
                local nx, ny = contact:getNormal()
                if ny < -0.5 then
                    if not pc.onGround then
                        pc.onGround = true
                        pc.jumps = pc.maxJumps
                    end
                else
                    pc.onGround = false
                end
            end
        else
            pc.inAir = true 
            pc.onGround = false
        end

        local velocity = Vector(physics.body:getLinearVelocity())
        local newVelocity = pc.velocity * pc.movementSpeed
        newVelocity.y = velocity.y
        local movementModifier = 10
        if pc.inAir then
            movementModifier = 2
        end
        local newVelocity = velocity + (newVelocity - velocity) * (dt * movementModifier)
        physics.body:setLinearVelocity( newVelocity.x, newVelocity.y)
    end
end

function PlayerUpdateSystem:requires()
    return {player = {"PlayerCharacter", "Physics"}, world = {"World", "Camera"}}
end

return PlayerUpdateSystem