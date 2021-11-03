local x = 0
local y = 0

local fullscreen = false
local width, height = love.graphics.getDimensions()

local debug_string = ".."

function love.resize(w,h)
    width = w
    height = h
end

function love.keypressed(k)
    debug_string = "cheese"
    if k == "`" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen)
        width, height = love.graphics.getDimensions()
    end
end

function love.draw()
    love.graphics.translate(width/2, height/2)

    love.graphics.setColor(1,1,0)
    love.graphics.circle("fill", x,y, 30)
end