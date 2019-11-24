require("Utils")
require("Bird")
require("Tube")

function love.load()
    _SpawnDelay = 1.90

    isDebugMode = false

    -- Расстояние между трубами.
    _DistanceBetweenTubes = 100

    _Width = love.graphics.getWidth()
    _Height = love.graphics.getHeight()

    _ScoreFont = love.graphics.newFont('/fonts/04B_19__.TTF', 42)

    -- region Graphics.
    local isNight = love.math.random(0, 1)
    if (isNight == 0) then
        _BackgroundImage = love.graphics.newImage('/sprites/background-day.png')
    else
        _BackgroundImage = love.graphics.newImage('/sprites/background-night.png')
    end
    _WelcomeMessage = love.graphics.newImage('/sprites/message.png')
    _TubeDrawable = love.graphics.newImage('/sprites/pipe-green.png')
    _TubeRedDrawable = love.graphics.newImage('/sprites/pipe-red.png')
    _Base = love.graphics.newImage('/sprites/base.png')
    _GameOver = love.graphics.newImage('/sprites/gameover.png')
    -- endregion.

    -- region Audio.
    _WingAudio = love.audio.newSource('/audio/wing.ogg', 'queue')

    _PointAudio = love.audio.newSource('/audio/point.ogg', 'static')
    -- endregion.

    _GameState = 'Welcome'

    _Bird = Bird:create()

    _LastSpawnedTime = 0

    _Scores = 0

    _TubesCount = 0

    _Tubes = {}
end

function love.update(dt)
    _Bird:update(dt)

    if (_GameState == 'Playing') then
        _LastSpawnedTime = _LastSpawnedTime + dt
        if (_LastSpawnedTime > _SpawnDelay) then
            _TubesCount = _TubesCount + 1
            table.insert(_Tubes, Tube:create(500, math.fmod(_TubesCount, 10) == 0))
            _LastSpawnedTime = 0

            -- Усложнение.
            if (_TubesCount > 20) then
                _SpawnDelay = 1.45
            end
        end

        for i = 0, #_Tubes - 1 do
            if (_Tubes[i]) then
                _Tubes[i]:update()
            end
        end
    end
end

function love.draw()
    -- Отрисовка фона.
    draw(_BackgroundImage)

    -- Отрисовка труб.
    for i = 0, #_Tubes - 1 do
        if (_Tubes[i]) then
            _Tubes[i]:draw()
        end
    end

    -- Отрисовка площадки.
    draw(_Base, 0, _Height - _Base:getHeight())
    
    _Bird:draw()

    if (_GameState == 'Welcome') then
        draw(_WelcomeMessage, 52, 75)
    elseif (_GameState == 'Playing') then
        showScore()
    elseif (_GameState == 'ShowResult') then
        showScore()

        draw(_GameOver, _Width / 2 - _GameOver:getWidth() / 2, 200)
    end
end

function love.keypressed(key)
    if (key == 'space') then
        if (_GameState == 'Welcome') then
            _GameState = 'Playing'
            _Bird:setState('Playing')
        elseif (_GameState == 'Playing') then
            _Bird:boost()
            _WingAudio:stop()
            _WingAudio:play()
        elseif (_GameState == 'ShowResult') then
            _GameState = 'Welcome'
            _Bird:setState('Idle')
            _Tubes = {}
            _Scores = 0
            _TubesCount = 0
        end
    end
end

function showScore()
    love.graphics.setFont(_ScoreFont)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(_Scores, _Width / 2 + 2, 52)

    love.graphics.setColor(1, 1, 1)
    love.graphics.print(_Scores, _Width / 2, 50)

    love.graphics.setColor(r, g, b, a)
end