require("vector")
require("mover")

function love.load()
    background = love.graphics.newImage("resources/background.png")
    love.window.setMode(background:getWidth(), background:getHeight())
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    ship_images = {}
    ship_images[1] = love.graphics.newImage("resources/ship_no_engine.png")
    ship_images[2] = love.graphics.newImage("resources/ship_engine_on.png")
    ship_images[3] = love.graphics.newImage("resources/ship_engine_full.png")

    player = Mover:create(ship_images, Vector:create(width/4 , height/4), Vector:create(0, 0))

    obstacle_images = {love.graphics.newImage("resources/obstacle_round.png")}
    obstacle = Mover:create(obstacle_images, Vector:create(width/24 , height/2), Vector:create(0.5, 2))

    obstacle.aVelocity = 0.1

    state = 1
    start_time = love.timer.getTime()

end

function love.update()  
    if love.keyboard.isDown("left") then 
        player.angle = player.angle - 0.05
    end

    if love.keyboard.isDown("right") then 
        player.angle = player.angle + 0.05
    end

    if love.keyboard.isDown("up") then 
        x = 0.1 * math.cos(player.angle)
        y = 0.1 * math.sin(player.angle)
        player:applyForce(Vector:create(x, y))
    end

    player:update()
    player:checkBounders()

    obstacle:update()
    obstacle:checkBounders()

    if player:checkObstacle(obstacle) == true then
        state = state + 1
    end

    if state == 1 then
        t = love.timer.getTime()
        time = t - start_time
    end

    if love.keyboard.isDown("space") then
        state = 1
        start_time = love.timer.getTime()
        player.location = Vector:create(200,200)
        obstacle.location = Vector:create(50, 50)
        player.velocity = Vector:create(0, 0)
    end

   

end

function love.draw()
    if state == 1 then
        love.graphics.draw(background, 0, 0)
        player:draw()
        obstacle:draw()
        love.graphics.print(time, 0, 0, 0, 1, 1)
    else
        love.graphics.print("Oops, you're dead :(\nPress space to play again \n Your total time: " .. time, width / 2 - 10, height / 2 - 10, 0, 1, 1)
    end

end




