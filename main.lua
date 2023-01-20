local dir = 1
local currentX, currentY = 0, 0
local width, height = love.graphics.getDimensions()
local vertices

local mouseX, mouseY = 300, 300
local mouseLmbPressed = false

GAMELOADED = false




local

entities = {
    totalEntities = 0
}
function entities.addEntity(entity)
    table.insert(entities, entity)
    entities.totalEntities = entities.totalEntities + 1
end

function entities.addSpecificEntity(entity, location)
    entities[location] = entity
    --table.insert(entities, location, entity)
    entities.totalEntities = entities.totalEntities + 1
end
function entities.getTotalEntities()
    return entities.totalEntities
end

function entities.draw()
    for i, v in pairs(entities) do
        if type(v) == "table" then
            v.draw()
        end
    end
end

function entities.update(dt)
    for i, v in pairs(entities) do
        if type(v) == "table" and not v.remove then
            v.update(dt)
        elseif type(v) == "table" and v.remove then
           table.remove(entities, tonumber(i))
           print("Removed Something   ...")

        end
    end
end

local ROC = {
    x1 = 0,
    y1 = 0,
    roc = nil,
}
function ROC.findROC(x, y)

    if x1 == nil or y1 == nil then
        print("uwuwuuwuwuwu\n\n")
    end

    roc = (y1 - y)/(x1 - x)

    x1, y1 = x, y
    return roc
end

function createBullet(x, y, r)
    local bullet = {
        bulletX_Loc = x or 0,
        bulletY_Loc = y or 0,
        bulletR_Radius = r or 10,

        distanceToShip = 0,
        timeAlive = 0,


        remove = false,
    }

    local shipX_Location, shipY_Location = entities.playerShip.getPlayerShipLocation()

    function bullet.update(dt)
        shipX_Location, shipY_Location = entities.playerShip.getPlayerShipLocation()
        bullet.timeAlive = bullet.timeAlive + dt * 100
        bullet.findDistanceToShip()

        if bullet.distanceToShip < bullet.bulletR_Radius * 1.3 and bullet.timeAlive > 100 then
            bullet.remove = true
        end
    end

    function bullet.findDistanceToShip()
        bullet.distanceToShip = math.sqrt((bullet.bulletX_Loc - shipX_Location) ^ 2 +
            (bullet.bulletY_Loc - shipY_Location) ^ 2)
        return bullet.distanceToShip
    end

    function bullet.draw()
        love.graphics.print(bullet.timeAlive, 250, 30)
        love.graphics.print(tostring(bullet.remove), 250, 50)

        --if not bullet.remove then
            love.graphics.circle("fill", bullet.bulletX_Loc, bullet.bulletY_Loc, bullet.bulletR_Radius)

            love.graphics.line(bullet.bulletX_Loc, bullet.bulletY_Loc, shipX_Location, shipY_Location)

            
        --end
    end

    function bullet.removeState()
        return bullet.remove
    end

    return bullet
end

function createPlayerShip(shipX, shipY)
    local playerShip = {
        shipX_Location = shipX or 0,
        shipY_Location = shipY or 0,

        shipX_Velocity = 0,
        shipY_Velocity = 0,

        absoluteAngle = 0,

        shipSpeed = 10,
        shipAngle = 0,

        shipDistToCursor = 0,
        shipX_DistToCursor = 0,
        shipY_DistToCursor = 0,



        remove = false,
    }

    


    local function updateDistances(mouseX, mouseY)
        playerShip.shipDistToCursor = math.sqrt((playerShip.shipX_Location - mouseX) ^ 2 +
            (playerShip.shipY_Location - mouseY) ^ 2)
        playerShip.shipX_DistToCursor = mouseX - playerShip.shipX_Location
        playerShip.shipY_DistToCursor = mouseY - playerShip.shipY_Location
    end

    function playerShip.findAbsoluteAngle()
        playerShip.absoluteAngle = math.atan2(
            playerShip.shipX_DistToCursor, playerShip.shipY_DistToCursor
        )
        return playerShip.absoluteAngle
    end

    local bulletLatch = true
    local function shootSimple()
        
        if love.mouse.isDown(2) and bulletLatch then
            entities.addEntity(createBullet(playerShip.shipX_Location, playerShip.shipY_Location))
            bulletLatch = false
        elseif not love.mouse.isDown(2) then
            bulletLatch = true
        end
    end

    local rateOfChange = 0

    function playerShip.update(dt)
        local mouseX, mouseY = love.mouse.getPosition()
        updateDistances(mouseX, mouseY)
        shootSimple()


        --make it so speed gets lower when player gets closer to curser?


        --[-[
        if love.mouse.isDown(1) and playerShip.shipSpeed < 300 then
            playerShip.shipSpeed = playerShip.shipSpeed + 3
        elseif love.mouse.isDown(1) == false and playerShip.shipSpeed > 0 then
            playerShip.shipSpeed = playerShip.shipSpeed - 3
        end
        --]]

        
        playerShip.absoluteAngle = playerShip.absoluteAngle - math.pi

        --[[
        if playerShip.shipDistToCursor < 2 then
            playerShip.shipAngle = playerShip.shipAngle
        else
            playerShip.shipAngle = playerShip.absoluteAngle
        end
        --]]

        playerShip.shipAngle = playerShip.absoluteAngle

        -- The sin/cos determin how much to go in a specific direction bi-directonally

        --if playerShip.shipX_Location ~= mouseX then
            playerShip.shipX_Location = playerShip.shipX_Location + playerShip.shipX_Velocity +
            (math.sin(playerShip.findAbsoluteAngle()) * playerShip.shipSpeed * dt)
        --end

        --if playerShip.shipY_Location ~= mouseY then
            playerShip.shipY_Location = playerShip.shipY_Location + playerShip.shipY_Velocity +
            (math.cos(playerShip.findAbsoluteAngle()) * playerShip.shipSpeed * dt)
        --end


        rateOfChange = ROC.findROC(playerShip.shipY_Location, playerShip.shipX_Location)
        print(rateOfChange)
    end

    function playerShip.draw()
        love.graphics.draw(
            simpleShipImg,
            playerShip.shipX_Location,
            playerShip.shipY_Location,
            playerShip.shipAngle * -1, 1, 1,
            simpleShipImg:getWidth() / 2,
            simpleShipImg:getHeight() / 2)
    end

    function playerShip.getPlayerShipSpeed()
        return playerShip.shipSpeed
    end

    function playerShip.getPlayerShipLocation()
        return playerShip.shipX_Location, playerShip.shipY_Location
    end

    function playerShip.getPlayerShipDistToCursor()
        return playerShip.shipDistToCursor
    end

    function playerShip.kill()
        playerShip.removie = true
        playerShip = nil
    end

    return playerShip
end

function love.load()
    simpleShipImg = love.graphics.newImage("Simple Ship 16x16.png")
    simpleDirections = love.graphics.newImage("Directions 73x49.png")
    entities.addSpecificEntity(createPlayerShip(100, 100), "playerShip") -- Try commenting this out that leads to the function value problem

    print("Program Started\n")
    GAMELOADED = true
end

local test = "uwu\n\n"

--[[
function love.mousepressed(mouseX, mouseY, button)
    local mouseLmbPressed = love.mouse.isDown(1) or false
    if button == 2 then
        
        local x, y = entities.playerShip.getPlayerShipLocation()
        
        
        
    end

    test = "createBullet called " .. entities.getTotalEntities()
end
]]

--local nosePointX1 = 40 + shipX_Location
--local nosePointY1 = 0 + shipY_Location

function love.update(dt)

    entities.update(dt)



    --shipX = shipX + distanceX/20
    --shipY = shipY + distanceY/20
    --shipX = 300
    --shipY = 300



    -- Front Spoke Thing
    --nosePointX1 = 40 + shipX_Location
    --nosePointY1 = 0 + shipY_Location

end

function love.draw()

    entities.draw()




    --local pointerAngle = shipAngle * -1  - math.pi/2

    --local pointXdirection = (nosePointX1 - shipX_Location)*math.cos(pointerAngle) - (nosePointY1 - shipY_Location)*math.sin(pointerAngle) + shipX_Location
    --local pointYdirection = (nosePointX1 - shipX_Location)*math.sin(pointerAngle) + (nosePointY1 - shipY_Location)*math.cos(pointerAngle) + shipY_Location

    --love.graphics.line(shipX_Location, shipY_Location, pointXdirection, pointYdirection)

    --speedomitor thing

    
    love.graphics.line(10, 50, 10, entities.playerShip.getPlayerShipSpeed() + 50)

    love.graphics.print(entities.playerShip.getPlayerShipDistToCursor(), 10, 10)
    love.graphics.print(entities.playerShip.getPlayerShipSpeed(), 10, 30)
    
    love.graphics.draw(simpleDirections, love.graphics.getWidth() - 83, 10 )

    --Old!
    --love.graphics.line(shipX, shipY, (pointX1 - shipX)*math.cos(shipAngle) - (pointY1 - shipY)*math.sin(shipAngle) + shipX, (pointX1 - shipX)*math.sin(shipAngle) + (pointY1 - shipY)*math.cos(shipAngle) + shipY)
    --https://danceswithcode.net/engineeringnotes/rotations_in_2d/rotations_in_2d.html



    love.graphics.print(entities.totalEntities, 250, 10)
    



end

function love.quit()
    print("Thanks for playing! Come back soon!")
end