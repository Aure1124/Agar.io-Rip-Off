local NOMNOMS_NUM = 60
local NOMNOMS_MIN_RADIUS = 5
local NOMNOMS_MAX_RADIUS = 25

local GRAPPLE_RADIUS = 265

local player = {
    x = 0,
    y = 0,
    r = 15,

    color = {1,1,0}
}

local grapple = {
    x = 0,
    y = 0,

    targets = {}
}

local time
local state

local fullscreen = true

love.window.setFullscreen(fullscreen)
local width, height = love.graphics.getDimensions()

local font = love.graphics.newFont(18)
local big_font = love.graphics.newFont(64)

local font = love.graphics.newFont(18)
local bigger_font = love.graphics.newFont(65)

local nomnoms = {}

function love.load()
    player.x = 0
    player.y = 0

    grapple.x = player.x
    grapple.y = player.y

    grapple.targets = {}

    time = 0
    state = "menu"

    nomnoms = {}
    while #nomnoms < NOMNOMS_NUM do
        local nom = {
            x = love.math.random(0, width - NOMNOMS_MAX_RADIUS) - (width - NOMNOMS_MAX_RADIUS)/2,
            y = love.math.random(0, height - NOMNOMS_MAX_RADIUS) - (height - NOMNOMS_MAX_RADIUS)/2,
            r = love.math.random(NOMNOMS_MIN_RADIUS, NOMNOMS_MAX_RADIUS),

            color = {
                love.math.random(32,255)/255,
                0.125,
                love.math.random(32,255)/255
            }
        }
        
        local invalid = (nom.x - player.x)^2 + (nom.y - player.y)^2 < (nom.r + player.r + 8)^2
        
        if not invalid then
            for i,v in ipairs(nomnoms) do
                if (nom.x - v.x)^2 + (nom.y - v.y)^2 < (nom.r + v.r + 8)^2 then
                    invalid = true
                    break
                end
            end

            if not invalid then
                table.insert(nomnoms, nom)
            end
        end
    end
end

function love.keypressed(k)
    if state ~= "menu" then
        if k == "r" then
            love.load()
        end
    end

    if k == "`" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen)
        width, height = love.graphics.getDimensions()
    elseif k == "escape" then
        love.event.quit()
    end
end

function love.mousepressed(mx,my, mb)
    mx = mx - width/2
    my = my - height/2

    if mb == 1 then
        if state == "win" then
            love.load()
        elseif state == "playing" then
            local fx = player.x
            local fy = player.y

            if #grapple.targets > 0 then
                fx = grapple.targets[#grapple.targets].x
                fy = grapple.targets[#grapple.targets].y
            end

            
            if (#grapple.targets == 0 or grapple.targets[#grapple.targets].in_circle)
            and math.sqrt((mx - fx)^2 + (my - fy)^2) < GRAPPLE_RADIUS then
                local in_circle = false
                for i,v in ipairs(nomnoms) do
                    if (mx - v.x)^2 + (my - v.y)^2 <= v.r^2 then
                        in_circle = true
                        break
                    end
                end

                table.insert(grapple.targets, { x=mx, y=my, in_circle=in_circle })
            end
        else
            if mx  > -(big_font:getWidth("Play") + 16)/2
            and mx <  (big_font:getWidth("Play") + 16)/2
            and my > -(big_font:getHeight() + 16)/2
            and my <  (big_font:getHeight() + 16)/2 then
                state = "playing"
            end
        end
    end
end

function love.update(dt)
    if state == "playing" then
        if #nomnoms == 0 then
            state = "win"
        end

        for i=#nomnoms,1,-1 do
            local nom = nomnoms[i]
            if (15 + nom.r)^2 > (player.x - nom.x)^2 + (player.y - nom.y)^2 then
                table.remove(nomnoms, i)
            end
        end

        if #grapple.targets > 0 then
            local target = grapple.targets[1]

            if math.abs(target.x - grapple.x) < 5 and math.abs(target.y - grapple.y) < 5 then
                if math.abs(grapple.x - player.x) < 5 and math.abs(grapple.y - player.y) < 5 then
                    table.remove(grapple.targets, 1)
                elseif target.in_circle then
                    player.x = player.x + (grapple.x - player.x)*5*dt
                    player.y = player.y + (grapple.y - player.y)*5*dt
                else
                    grapple.x = grapple.x + (player.x - grapple.x)*5*dt
                    grapple.y = grapple.y + (player.y - grapple.y)*5*dt

                    grapple.targets[1].x = grapple.x
                    grapple.targets[1].y = grapple.y
                end
            else
                grapple.x = grapple.x + (target.x - grapple.x)*5*dt
                grapple.y = grapple.y + (target.y - grapple.y)*5*dt
            end
        else

        end

        time = time + dt
    end
end

function love.draw()
    love.graphics.translate(width/2, height/2)

    if state == "playing" then
        love.graphics.line(player.x, player.y, grapple.x, grapple.y)

        for i,v in ipairs(nomnoms) do
            love.graphics.setColor(v.color)
            love.graphics.circle("fill", v.x,v.y, v.r)
        end

        love.graphics.setColor(player.color)
        love.graphics.circle("fill", player.x, player.y, player.r)

        local formatted_time = math.floor(time * 100)/100
        love.graphics.setFont(font)
        love.graphics.print(formatted_time)
    elseif state == "win" then
        love.graphics.setColor(player.color)
        love.graphics.setFont(font)
        love.graphics.print("Win")

        local formatted_time = math.floor(time * 100)/100
        love.graphics.print(formatted_time, 0, -15)
    else
        love.graphics.setColor(1,1,1)
        love.graphics.setLineWidth(4)
        love.graphics.setFont(big_font)

        love.graphics.rectangle("line", -(big_font:getWidth("Play") + 16)/2, -(big_font:getHeight() + 16)/2, big_font:getWidth("Play") + 16, big_font:getHeight() + 16)
        love.graphics.print("Play", -big_font:getWidth("Play")/(2), -big_font:getHeight()/(2))
    end
end