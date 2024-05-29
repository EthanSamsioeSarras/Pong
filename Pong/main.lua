--[[
    GD50 2018
    Pong Remake

    -- Main Program --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Originally programmed by Atari in 1972. Features two
    paddles, controlled by players, with the goal of getting
    the ball past your opponent's edge. First to 10 points wins.

    This version is built to more closely resemble the NES than
    the original Pong machines or the Atari 2600 in terms of
    resolution, though in widescreen (16:9) so it looks nicer on 
    modern systems.
]]

local push = require 'push'

Class = require 'class'

require 'Paddle'

require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    math.randomseed(os.time())

    SmallFont = love.graphics.newFont('font.ttf', 8)
    LargeFont = love.graphics.newFont('font.ttf', 8)
    ScoreFont = love.graphics.newFont('font.ttf', 32)

    love.graphics.setFont(SmallFont)

    Sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    Player1Score = 0
    Player2Score = 0

    ServingPlayer = 1

    Player1 = Paddle(10, 30, 5, 20)
    Player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
    Ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    Gamestate = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if Gamestate == 'serve' then
        Ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            Ball.dx = math.random(140, 200)
        else
            Ball.dx = -math.random(140, 200)
        end


    elseif Gamestate == 'play' then
        if Ball:collides(Player1) then
            Ball.dx = -Ball.dx * 1.03
            Ball.x = Player1.x + 5

            if Ball.dy < 0 then
                Ball.dy = -math.random(10, 150)
            else
                Ball.dy = math.random(10, 150)
            end

            Sounds['paddle_hit']:play()
        end

        if Ball:collides(Player2) then
            Ball.dx = -Ball.dx * 1.03
            Ball.x = Player2.x -4

            if Ball.dy < 0 then
                Ball.dy = -math.random(10, 150)
            else
                Ball.dy = math.random(10, 150)
            end

            Sounds['paddle_hit']:play()
        end

        if Ball.y <= 0 then
            Ball.y = 0
            Ball.dy = -Ball.dy
            Sounds['wall_hit']:play()
        end

        if Ball.y >= VIRTUAL_HEIGHT - 4 then
            Ball.y = VIRTUAL_HEIGHT - 4
            Ball.dy = -Ball.dy
            Sounds['wall_hit']:play()
        end
        if Ball.x < 0 then
            ServingPlayer = 1
            Player2Score = Player2Score + 1
            Sounds['score']:play()
    
            if Player2Score == 10 then
                WinningPlayer = 2
                Gamestate = 'done'
            else
                Gamestate = 'serve'
                Ball:reset()
            end
        end
    
        if Ball.x > VIRTUAL_WIDTH then
            ServingPlayer = 2
            Player1Score = Player1Score + 1
            Sounds['score']:play()
    
            if Player1Score == 10 then
                WinningPlayer = 1
                Gamestate = 'done'
            else
                Ball:reset()
                Gamestate = 'serve'
            end
        end
    end


    if love.keyboard.isDown('w') then
        Player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        Player1.dy = PADDLE_SPEED
    else
        Player1.dy = 0
    end
 
    if love.keyboard.isDown('up') then
        Player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        Player2.dy = PADDLE_SPEED
    else
        Player2.dy = 0
    end

    if Gamestate == 'play' then
        Ball:update(dt)
    end

    Player1:update(dt)
    Player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if Gamestate == 'start' then
            Gamestate = 'serve'
        elseif Gamestate == 'serve' then
            Gamestate = 'play'
        elseif Gamestate == 'done' then
            Gamestate = 'serve'

            Ball:reset()

            Player1Score = 0
            Player2Score = 0

            if WinningPlayer == 1 then
                ServingPlayer = 2
            else
                ServingPlayer = 1
            end
        end
    end
end

function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    love.graphics.setFont(SmallFont)

    DisplayScore()

    if Gamestate == 'start' then
        love.graphics.setFont(SmallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
         love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif Gamestate == 'serve' then
        love.graphics.setFont(SmallFont)
        love.graphics.printf('Player '.. tostring(ServingPlayer) .. "'s serve!",
         0, 10, VIRTUAL_WIDTH, 'center')
         love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif Gamestate == 'play' then
    
    elseif Gamestate == 'done' then
        love.graphics.setFont(LargeFont)
        love.graphics.printf('Player ' .. tostring(WinningPlayer) .. ' wins!',
        0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(SmallFont)
        love.graphics.printf('Press Enter to restart', 0, 30, VIRTUAL_WIDTH, 'center')
    end
    love.graphics.setFont(ScoreFont)
    love.graphics.print(tostring(Player1Score), VIRTUAL_WIDTH / 2 - 50, 
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(Player2Score), VIRTUAL_WIDTH / 2 + 30,
        VIRTUAL_HEIGHT / 3)

    Player1:render()
    Player2:render()

    Ball:render()

    DisplayFPS()

    push:apply('end')
end

function DisplayFPS()
    love.graphics.setFont(SmallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

function DisplayScore()
    love.graphics.setFont(ScoreFont)
    love.graphics.print(tostring(Player1Score), VIRTUAL_WIDTH / 2 -50,
        VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(Player2Score), VIRTUAL_WIDTH / 2 +30,
        VIRTUAL_HEIGHT / 3)
end