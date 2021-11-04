local x = 0
local y = 0

local gx, gy = x, y
local cx, cy = x, y

local fullscreen = false
local width, height = love.graphics.getDimensions()
local fwidth, fheight = (1440 - 50), (900 - 50)

local nomnoms = {}

function love.load()
    while #nomnoms < 50 do
        local nom = {
            x = love.math.random(0,fwidth) - fwidth/2,
            y = love.math.random(0,fheight) - fheight/2,
            r = love.math.random(5,25),

            c = {
                love.math.random (0,100)/100,
                0,
                love.math.random (0,100)/100
            }
        }

        local invalid = (nom.x - x)^2 + (nom.y - y)^2 < (15 + nom.r + 8)^2

        if not invalid then
            for i,v in ipairs(nomnoms) do
                invalid = invalid or ((nom.x - v.x)^2 + (nom.y - v.y)^2 < (nom.r + v.r + 8)^2)
            end

            if not invalid then
                table.insert(nomnoms, nom)
            end
        end
    end
end

function love.resize(w,h)
    width = w
    height = h
end

function love.keypressed(k)
    if k == "`" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen)
        width, height = love.graphics.getDimensions()
    end
end

function love.mousepressed(mx,my, k)
    if k == 1 and math.sqrt((mx - width/2 - x)^2 + (my - height/2 - y)^2) < 350
    and math.abs(gx - cx) < 5 and math.abs(gy - cy) < 5 then
        cx = x
        cy = y

        gx = mx - width/2
        gy = my - height/2
    end
end

function love.update(dt)
    if gx and gy then
        if math.abs(gx - cx) > 1 then
            cx = cx + (gx - cx)*dt*5
        end
        
        if math.abs(gy - cy) > 1 then
            cy = cy + (gy - cy)*dt*5
        end
    end
end

function love.draw()
    love.graphics.translate(width/2, height/2)
    
    if gx and gy then
        love.graphics.line(x,y, cx,cy)
    end
    
    for i,v in ipairs(nomnoms) do
        love.graphics.setColor(v.c)
        love.graphics.circle("fill", v.x,v.y, v.r)
    end

    love.graphics.setColor(1,1,0)
    love.graphics.circle("fill", x,y, 15)

end