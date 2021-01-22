Mover = {}
Mover.__index = Mover

function Mover:create(images, location, velocity, auto)
    local mover = {}
    setmetatable(mover, Mover)
    mover.location = location
    mover.velocity = velocity
    mover.acceleration = Vector:create(0,0)
    mover.aAcceleration = 0
    mover.aVelocity = 0
    mover.auto = auto or false
    mover.angle = 0 
    mover.maxSpeed = 4
    mover.maxForce = 0.1
    mover.images = images
    return mover
end

function Mover:applyForce(force) 
    self.acceleration:add(force)
end

function Mover:checkBounders()
    if self.location.x < 30 then 
        self.location.x = width- 30
    elseif self.location.x > width - 30 then 
        self.location.x = 30
    end

    if self.location.y > height - 30 then 
        self.location.y = 30
    elseif self.location.y < 30 then 
        self.location.y = height - 30
    end
end

function Mover:checkObstacle(object)
    local mov_points = self:getPoints()
    local obj_points = object:getPoints()
    local point, point1

    axis_x = {}
    axis_y = {}

    for i = 1, #mov_points - 1 do
        point = mov_points[i]
        point1 = mov_points[i+1]
        local vec1 = Vector:create(point[1], point[2])
        local vec2 = Vector:create(point1[1], point1[2])
        vec1:sub(vec2)
        local perp = Vector:create(-1 * vec1.y, vec1.x)
        perp:norm()
        table.insert(axis_x, perp)
    end

    for i=1, #obj_points - 1 do
        point = obj_points[i]
        point1 = obj_points[i+1]
        local vect1 = Vector:create(point[1], point[2])
        local vect2 = Vector:create(point1[1], point1[2])
        vect1:sub(vect2)
        local perp1 = Vector:create(-1 * vect1.y, vect1.x)
        perp1:norm()
        table.insert(axis_y, perp1)
    end

    for i = 1, #axis_x do
        local ax = axis_x[i]
        local p1 = self:projection(ax)
        local p2 = self:projection(ax, object)
        if p1:overlap(p2) == false then
            return false
        end
    end

    for i = 1, #axis_y do
        local axx = axis_y[i]
        local pp1 = self:projection(axx)
        local pp2 = self:projection(axx, object)
        if pp1:overlap(pp2) == false then
            return false
        end
    end
    return true
end

function Mover:getPoints()
    local x = self.location.x
    local y = self.location.y

    img = self.images[1]
    local x1 = img:getWidth() / 16
    local y1 = img:getHeight() / 16

    points = {{x, y}, {x + x1, y}, {x + x1, y + y1}, {x ,y + y1}, {x, y}}

    return points      
end

function Mover:projection(axis, object)
    local mov_points = self:getPoints()

    if object then
        local obj_points = object:getPoints()
        local min = axis:dots(Vector:create(obj_points[1][1], obj_points[1][2]))
        local max = min

        for i = 2, #obj_points do
            temp = axis:dots(Vector:create(obj_points[i][1], obj_points[i][2]))

            if temp < min then
                min = temp 
            elseif temp > max then
                max = temp 
            end
        end
    
        proj = Vector:create(min,max)

    else 
        local min = axis:dots(Vector:create(mov_points[1][1], mov_points[1][2]))
        local max = min

        for i = 2, #mov_points do
            temp = axis:dots(Vector:create(mov_points[i][1], mov_points[i][2]))

            if temp < min then
                min = temp 
            elseif temp > max then
                max = temp 
            end
        end

        proj = Vector:create(min,max)

    end

    return proj
end

function Mover:attract(objects) 
    for i = 1, objects.n do 
            
        dir = (self.location - objects.objs[i].location)
        distance = dir:mag()
        if distance then 
            if distance < 5 then 
                distance = 5
            end
            if distance > 25 then 
                distance = 25 
            end
            dir = dir:norm()
            if dir then 
                
                strength = (G * self.weight * objects.objs[i].weight) / (distance * distance)
                force = dir * strength
                objects.objs[i]:applyForce(force)
            end
        end

    end
end

function Mover:draw()
    love.graphics.push()
    love.graphics.translate(self.location.x, self.location.y)
    love.graphics.rotate(self.angle + math.pi/2)
    n = 1
    if #self.images > 1 then 
        mag = self.velocity:mag()
        if mag < 1  then 
            n = 1
        elseif mag >=1 and mag < 3 then
            n = 2
        else
            n = 3
        end
    end
    image = self.images[n]
    love.graphics.draw(image, -image:getWidth() / 16, -image:getHeight() / 16, 0, 1/8, 1/8)
    
    love.graphics.pop()
end

function Mover:update()
    self.velocity:add(self.acceleration)
    self.location:add(self.velocity)
    self.aVelocity = self.aVelocity + self.aAcceleration
    self.angle = self.angle + self.aVelocity
    self.acceleration:mul(0)
end

