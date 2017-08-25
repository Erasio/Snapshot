local PlayerInputSystem = class("PlayerInputSystem", System)

function PlayerInputSystem:fireEvent(event)
    local world, camera
    for k, tWorld in pairs(self.targets.world) do
        world = tWorld:get("World")
    end

    for k, entity in pairs(self.targets.player) do
    	local pc = entity:get("PlayerCharacter")
    	if event.key == "w" then
    		if event.mode == "pressed" then
    			if pc.jumps > 0 then
    				local physics = entity:get("Physics")
    				local vx, vy = physics.body:getLinearVelocity()
    				vy = -230
    				physics.body:setLinearVelocity(vx, vy)

    				pc.jumps = pc.jumps - 1
    			end
    		end
    	elseif event.key == "s" then

    	elseif event.key == "a" then
    		if event.mode == "pressed" then 
    			pc.velocity.x = pc.velocity.x - 1
    		else
    			pc.velocity.x = pc.velocity.x + 1
    		end
    	elseif event.key == "d" then
    		local pc = entity:get("PlayerCharacter")
    		if event.mode == "pressed" then 
    			pc.velocity.x = pc.velocity.x + 1
    		else
    			pc.velocity.x = pc.velocity.x - 1
    		end
        elseif event.key == "f" then
            if event.mode == "pressed" then
                world:toggleMode()
            end
    	end
    end
end

function PlayerInputSystem:requires()
    return {player = {"PlayerCharacter", "Physics"}, world = {"World", "Camera"}}
end

return PlayerInputSystem