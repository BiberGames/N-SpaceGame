

-- ########### Variables ###########
function Variables()
    running = false
    time = 0
    playerY = platform.window:width() / 2
    MouseX = 0

    PlayerBB = {}
    RockBB = {}

    maxRockCount = 5
    RockX = {} -- Rock X Position
    RockY = {} -- Rock Y Position
    RockRotation = {}

    maxStarCount = 30
    StarX = {} -- Star X Position
    StarY = {} -- Star Y Position
    StarRotation = {}

    logoYPosition = -64

    score = 0
    if var.recall("highScore") then
        highScore = var.recall("highScore")
    else
        highScore = 0
    end
end
-- ########### Variables ###########

-- ########### Setup ###########
function on.construction()
    Variables()
    var.store("highScore", 0)
    images = {}
    for img_name, img_resource in pairs(_R.IMG) do
        images[img_name] = image.new(img_resource)
    end

    SpawnRocks()
    SpawnStars()

    PlayerBB = {MouseX - 32, platform.window:height() - 45, 64, 64}

    timer.start(0.01)
    cursor.set("resize column")
end

function on.timer()
    time = time + 1

    -- Intro timer
    if time == 70 then
        running = true
    end

    -- updating the game
    platform.window:invalidate()
end
-- ########### Setup ###########

-- ########### Flying objects ###########
function SpawnStars()
    for i=1, maxStarCount do
        StarY[i] = math.random(-128, platform.window:height())
        StarX[i] = math.random(0, platform.window:width() - 64)
        StarRotation[i] = math.random(0, 359);
    end
end

function DrawStars(gc)
    for i=1, maxStarCount do
        StarY[i] = StarY[i] + 0.5

        if StarY[i] > platform.window:height() + 8 then
            StarY[i] = math.random(-128, platform.window:height())
            StarX[i] = math.random(0, platform.window:width())
        end

        gc:drawImage(images.star:rotate(StarRotation[i]), StarX[i]-8, StarY[i]-8)
    end
end

function SpawnRocks()
    for i=1, maxRockCount do
        RockY[i] = math.random(-128, 0)
        RockX[i] = math.random(0, platform.window:width() - 64)
        RockRotation[i] = math.random(0, 359);
    end
end

function DrawRocks(gc)
    for i=1, maxRockCount do
        RockY[i] = RockY[i] + 1

        RockBB[i] = {RockX[i]-32, RockY[i]-32, 32, 32}

        if RockY[i] > platform.window:height() + 32 then
            score = score + 1
            RockY[i] = math.random(-128, 0)
            RockX[i] = math.random(0, platform.window:width())
        end

        --DrawBoundingBox(gc, RockX[i]-32, RockY[i]-32, 32, 32)
        gc:drawImage(images.rock:rotate(RockRotation[i]), RockX[i]-32, RockY[i]-32)
    end
end
-- ########### Flying objects ###########

-- ########### Colision Detection ###########
function ReturnCollision(box1x, box1y, box1w, box1h, box2x, box2y, box2w, box2h)
    if box1x > box2x + box2w - 1 or -- Is box1 on the right side of box2?
       box1y > box2y + box2h - 1 or -- Is box1 under box2?
       box2x > box1x + box1w - 1 or -- Is box2 on the right side of box1?
       box2y > box1y + box1h - 1    -- Is b2 under b1?
    then
        return false                -- No collision.  Yay!
    else
        return true                 -- Yes collision.  Ouch!
    end
end

function CheckCollision()
    for i=1, maxRockCount do
        if ReturnCollision(MouseX - 32, platform.window:height() - 45, 64, 64, RockX[i]-32, RockY[i]-32, 32, 32) then
            StoreScore()
            highScore = var.recall("highScore")
            score = 0
        end
    end
end

function DrawBoundingBox(gc, box1x, box1y, box1w, box1h)
    gc:setColorRGB(255, 0, 0)
	gc:drawRect(box1x, box1y, box1w, box1h)
end
-- ########### Colision Detection ###########

-- ########### Input ###########
function on.mouseMove(x,y)
    MouseX = x
end
-- ########### Input ###########

function StoreScore()
    if score > highScore then
        var.store("highScore", score)
    end
end

function on.paint(gc)
    if running == false then
        Intro(gc)
    else
        GamePlay(gc)
    end
end

function Intro(gc)
    -- Background Color
    gc:setColorRGB(244, 245, 250)
    gc:fillRect(0, 0, platform.window:width(), platform.window:height())

    -- Logo
    gc:drawImage(images.bglogo, (platform.window:width() / 2)-64, (platform.window:height() / 2 ) - 64)

    -- Drawing HUD
    gc:setColorRGB(128, 128, 128)
    gc:drawString("(c) BenjaGames 2023 / BENJA_303#8451" .. score, 0, 0, "top")
end

function GamePlay(gc)
    CheckCollision()

    -- Background Color
    gc:setColorRGB(21, 34, 56)
    gc:fillRect(0, 0, platform.window:width(), platform.window:height())

    DrawStars(gc)
    DrawRocks(gc)

    -- Drawing Player
    gc:drawImage(images.spaceship, MouseX - 32, platform.window:height() - 45)
    --DrawBoundingBox(gc, MouseX - 32, platform.window:height() - 45, 64, 64)

    -- Drawing HUD
    gc:setColorRGB(244, 245, 250)
    gc:drawString("Score: " .. score, 0, 0, "top")
    gc:drawString("High Score: " .. highScore, 0, 16, "top")
end
