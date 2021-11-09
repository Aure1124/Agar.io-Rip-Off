local x, y = 0, 0
local nx, ny = x, y

local gx, gy = x, y
local cx, cy = x, y

local time = 0
local on_menu = true
local win = false

local fullscreen = false
local width, height = love.graphics.getDimensions()
local fwidth, fheight = (1440 - 50), (900 - 50)

local font = love.graphics.newFont(18)
local bigger_font = love.graphics.newFont(65)

local nomnoms = {}

function love.load()
    x, y = 0, 0
    nx, ny = x, y

    gx, gy = x, y
    cx, cy = x, y

    time = 0
    on_menu = true
    win = false

    nomnoms = {}
    while #nomnoms < 60 do
        local nom = {
            x = love.math.random(0,fwidth) - fwidth/2,
            y = love.math.random(0,fheight) - fheight/2,
            r = love.math.random(5,25),

            c = {
                love.math.random (10,100)/100,
                0.1,
                love.math.random (10,100)/100
            }
        }

        local invalid = (nom.x - x)^2 + (nom.y - y)^2 < (15 + nom.r + 8)^2

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

function love.resize(w,h)
    width = w
    height = h
end

function love.keypressed(k)
    if not (on_menu or win) then
        if k == "r" then
            love.load()
        end
    end

    if k == "`" then
        fullscreen = not fullscreen
        love.window.setFullscreen(fullscreen)
        width, height = love.graphics.getDimensions()
    end
end

function love.mousepressed(mx,my, k)
    mx = mx - width/2
    my = my - height/2

    if win then
        love.load()
    elseif on_menu then
        if mx > -(bigger_font:getWidth("Play") + 16)/2
        and mx <  (bigger_font:getWidth("Play") + 16)/2
        and my > -(bigger_font:getHeight() + 16)/2
        and my <  (bigger_font:getHeight() + 16)/2 then
            on_menu = false
        end
    else
        if k == 1 and math.sqrt((mx - x)^2 + (my - y)^2) < 265 then
            gx = mx
            gy = my

            cx = x
            cy = y

            local in_circle = false

            for i,nom in ipairs(nomnoms) do
                if (nom.x - mx)^2 + (nom.y - my)^2 < nom.r^2 then
                    in_circle = true
                    break
                end
            end

            if in_circle then
                nx = mx
                ny = my
            else
                nx = x
                ny = y
            end
        end
    end
end

function love.update(dt)
    if on_menu then
    elseif win then
    else
        for i=#nomnoms,1,-1 do
            local nom = nomnoms[i]
            if (15 + nom.r)^2 > (x - nom.x)^2 + (y - nom.y)^2 then
                table.remove(nomnoms, i)
            end
        end

        if math.abs(gx - cx) < 5 and math.abs(gy - cy) < 5 then
            if math.abs(x - nx) < 5 and math.abs(y - ny) < 5 then
                gx = x
                gy = y
            else
                if math.abs(nx - x) > 1 then
                    x = x + (nx - x)*dt*5
                end
                
                if math.abs(ny - y) > 1 then
                    y = y + (ny - y)*dt*5
                end
            end
        else
            if math.abs(gx - cx) > 5 then
                cx = cx + (gx - cx)*dt*5
            end
            
            if math.abs(gy - cy) > 5 then
                cy = cy + (gy - cy)*dt*5
            end
        end
        time = time + (dt)
        win = #nomnoms == 0
    end
end

function love.draw()
    love.graphics.translate(width/2, height/2)

    if win then
        love.graphics.setColor(1,1,0)
        love.graphics.print("Win")
        love.graphics.setFont(font)
        love.graphics.print(math.floor(time * 100)/100, 0, -15)

    elseif on_menu then
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(bigger_font)

        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", -(bigger_font:getWidth("Play") + 16)/2, -(bigger_font:getHeight() + 16)/2, bigger_font:getWidth("Play") + 16, bigger_font:getHeight() + 16)
        love.graphics.print("Play", -bigger_font:getWidth("Play")/(2), -bigger_font:getHeight()/(2))
        love.graphics.print("Play", -bigger_font:getWidth("Play")/(2), -bigger_font:getHeight()/(2))

    else
        
        if gx and gy then
            love.graphics.line(x,y, cx,cy)
        end
        
        for i,v in ipairs(nomnoms) do
            love.graphics.setColor(v.c)
            love.graphics.circle("fill", v.x,v.y, v.r)
        end

        love.graphics.setColor(1,1,0)
        love.graphics.circle("fill", x,y, 15)

        love.graphics.setFont(font)
        love.graphics.print(math.floor(time * 100)/100)
    end
end
