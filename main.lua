isEven = true;
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
paddleWidth = 20 
paddleHeight = 100
ballWidth = 15
ballHeight = 15
ballSpeed = 400
paddleSpeed = 400
whichPaddleToCheck = ""
startTime = 0
collisionPoint = 0
player1Score = 0
player2Score = 0
loadTime = 0
lastScoredPlayer = ""

function love.load()
    hitSound = love.audio.newSource("hit.wav", "static")
    scoreSound = love.audio.newSource("score.wav", "static")
    loadTime = os.clock()
    math.randomseed(os.time())
    love.window.setTitle("Pong")
    smallFont = love.graphics.newFont('font.ttf', 30)
    scoreFont = love.graphics.newFont('font.ttf', 120)
    informationFont = love.graphics.newFont('font.ttf', 15)
    love.graphics.setFont(smallFont)
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = false, resizable = false, vsync = true})
    player1X = 20
    player2X = love.graphics.getWidth() - paddleWidth - 20
    player1Y = love.graphics.getHeight() - paddleHeight - 20
    player2Y = 20
    ballX = WINDOW_WIDTH / 2
    ballY = WINDOW_HEIGHT / 2
    gameState = "start"
    
    ballDX = math.random(2) == 1 and ballSpeed or -ballSpeed
    ballDY = math.random(-50, 50)
end

function love.draw()
    love.graphics.clear(40/255, 45/255, 52/255, 255/255)

    if os.clock() - loadTime < 5 then
        love.graphics.setFont(informationFont)
        love.graphics.printf("Press R to restart the game. \nPress Enter to start.", 10, 20, love.graphics.getWidth(), "left")
    end
    love.graphics.setFont(smallFont)
    love.graphics.printf(tostring(player1Score) .. "  " .. tostring(player2Score), 0, 50, love.graphics.getWidth(), "center")
    if gameState == "finished" then
        if player1Score == 2 then
            love.graphics.printf("Player 1 Won", 0, 100, love.graphics.getWidth(), "center")
        else
            love.graphics.printf("Player 2 Won", 0, 100, love.graphics.getWidth(), "center")
        end
        love.graphics.setColor(1, 1, 1, 0.4)
        love.graphics.printf("R to Restart, ESC to quit.", 0, 150, love.graphics.getWidth(), "center")
    end
    
    love.graphics.setColor(0.5, 1, 0.3, 1)
    -- left paddle
    love.graphics.rectangle("fill", player1X, player1Y, paddleWidth, paddleHeight)
    -- right paddle
    love.graphics.rectangle("fill", player2X, player2Y, paddleWidth, paddleHeight)
    -- ball
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", ballX, ballY, ballWidth, ballHeight)
end

function detectCollision(paddle)
    if paddle == "right" then 
        if ballX + ballWidth < player2X then
            return false
        end
        if ballY > player2Y + paddleHeight or ballY + ballHeight < player2Y then
            return false
        end 

        collisionPoint = math.floor(ballY + ballHeight / 2 - player2Y)
        adjustCollisionPoint()
        return true
    else
        if ballX > player1X + paddleWidth then
            return false
        end
        if ballY > player1Y + paddleHeight or ballY + ballHeight < player1Y then
            return false
        end
        collisionPoint = math.floor(ballY + ballHeight / 2 - player1Y)
        adjustCollisionPoint()
        return true
    end
end

function adjustCollisionPoint()
    if collisionPoint < 0 then
        collisionPoint = 0
    elseif collisionPoint > 100 then
        collisionPoint = 100
    end
end

function resetGame(state)
    gameState = state
    ballX = WINDOW_WIDTH / 2
    ballY = WINDOW_HEIGHT / 2
    ballDY = math.random(-50, 50) * 1.5
    if state == "start" then
        ballDX = math.random(2) == 1 and ballSpeed or -ballSpeed
    elseif state == "play" then
        ballDX = lastScoredPlayer == "player1" and -ballSpeed or ballSpeed
    end
end
function love.update(dt)
    if love.keyboard.isDown("w") then
        player1Y = math.max(0, player1Y - paddleSpeed * dt)
    elseif love.keyboard.isDown("s") then
        player1Y = math.min(love.graphics.getHeight() - paddleHeight, player1Y + paddleSpeed * dt)
    end

    if love.keyboard.isDown("up") then
        player2Y = math.max(0, player2Y - paddleSpeed * dt)
    elseif love.keyboard.isDown("down") then
        player2Y = math.min(love.graphics.getHeight() - paddleHeight, player2Y + paddleSpeed * dt)
    end

    if gameState == "play" then
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
    end

    if ballX > player2X + paddleWidth + 20 then
        lastScoredPlayer = "player1"
        scoreSound:play()
        resetGame("play")
        player1Score = player1Score + 1
        if player1Score == 10 then
            gameState = "finished"
        end
    elseif ballX + ballWidth < player1X - 20 then
        lastScoredPlayer = "player2"
        scoreSound:play()
        resetGame("play")
        player2Score = player2Score + 1
        if player2Score == 10 then
            gameState = "finished"
        end
    end

    -- collision detection 
    if ballX < love.graphics.getWidth() / 2 then
        whichPaddleToCheck = "left"
    else 
        whichPaddleToCheck = "right"
    end

    -- this startTime variable prevents calling the method more than once in a second after a collision occurs.
    if startTime == 0 or os.clock() - startTime > 1 then
        if detectCollision(whichPaddleToCheck) == true then
            hitSound:play()
            startTime = os.clock()
            if collisionPoint <= 50 then
                ballDY = (collisionPoint - 50) * 1.5
            else
                ballDY = (collisionPoint / 2) * 1.5
            end
            ballDX = -ballDX
        end
    end
    
    -- this condition checks if the ball above or below the screen, if so negates the y velocity of the ball.
    if ballY < 0 or ballY + ballHeight > love.graphics.getHeight() then
        ballDY = -ballDY
    end
    -- end of collision detection
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    
    if key == "enter" or key == "return" then
        if gameState == "start" then
            gameState = "play"
        end
    end

    if key == "r" then
        resetGame("start")
        player1Score = 0
        player2Score = 0
    end
end
