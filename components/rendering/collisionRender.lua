local CollisionRender = Component.create("CollisionRender")

function CollisionRender:initialize()
end

function CollisionRender:draw(body, shape, ox, oy)
	if shape and body then
		ox = ox or 0
		oy = oy or 0
		if shape:typeOf("CircleShape") then
	        local cx, cy = shape:getPoint()
	        love.graphics.circle("fill", body:getX() + cx + ox, body:getY() + cy + oy, shape:getRadius())
	    elseif shape:typeOf("PolygonShape") then
	        local points = {body:getWorldPoints(shape:getPoints())}
	        for i=1, #points, 2 do
	        	points[i] = points[i] + ox
	        	points[i+1] = points[i+1] + oy
	        end
	        love.graphics.polygon("fill", points)
	    else
	        local points = {body:getWorldPoints(shape:getPoints())}
	        for i=1, #points, 2 do
	        	points[i] = points[i] + ox
	        	points[i+1] = points[i+1] + oy
	        end
	        love.graphics.line(points)
	    end
	end
end

return CollisionRender