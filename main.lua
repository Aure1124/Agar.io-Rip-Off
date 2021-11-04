local x = 0
local y = 0

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

            c = {0,0,1}
        }

        local invalid = false

        for i,v in ipairs(nomnoms) do
            invalid = invalid or ((nom.x - v.x)^2 + (nom.y - v.y)^2 < (nom.r + v.r + 8)^2) or (nom.x^2 + nom.y^2 < (15 + 8)^2)
        end

        if not invalid then
            table.insert(nomnoms, nom)
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

function love.draw()
    love.graphics.translate(width/2, height/2)
    
    for i,v in ipairs(nomnoms) do
        love.graphics.setColor(v.c)
        love.graphics.circle("fill", v.x,v.y, v.r)
    end

    love.graphics.setColor(1,1,0)
    love.graphics.circle("fill", x,y, 15)
end