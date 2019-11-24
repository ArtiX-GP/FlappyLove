Bird = {}
Bird.__index = Bird

function Bird:create()
    local bird = {}
    setmetatable(bird, Bird)

    local time = 0.6

    _BirdWidth = 34
    _BirdHeight = 24

    local type = love.math.random(0, 2)
    if (type == 0) then
        _BirdAnimation = createAnimation(love.graphics.newImage("sprites/bluebird.png"), _BirdWidth, _BirdHeight, time)
    elseif (type == 1) then
        _BirdAnimation = createAnimation(love.graphics.newImage("sprites/redbird.png"), _BirdWidth, _BirdHeight, time)
    else
        _BirdAnimation = createAnimation(love.graphics.newImage("sprites/yellowbird.png"), _BirdWidth, _BirdHeight, time)
    end

    _BirdFailAudio = love.audio.newSource('/audio/hit.ogg', 'static')
    _BirdFail2Audio = love.audio.newSource('/audio/die.ogg', 'static')

    _BirdCurrentY = _Height / 2 - _BirdHeight / 2

    _BirdAngleDeg = 0

    -- Координата Y, в которой последний раз тыркнули на птаху.
    _BirdLastTouchY = _BirdCurrentY

    _BirdBoost = 0

    _BirdState = 'Idle'

    return bird
end

function Bird:setState(s)
    if (s == _BirdState) then
        return nil
    end

    _BirdState = s
    if (s == 'Idle') then
        _BirdCurrentY = _Height / 2 - _BirdHeight / 2
        _BirdAngleDeg = 0

        _BirdLastTouchY = _BirdCurrentY
    elseif (s == 'Failed') then
        _BirdFailAudio:play()
        _BirdFail2Audio:play()
        _GameState = 'ShowResult'
    end
end

function Bird:update(dt)
    _BirdAnimation.currentTime = _BirdAnimation.currentTime + dt
    if _BirdAnimation.currentTime >= _BirdAnimation.duration then
        _BirdAnimation.currentTime = _BirdAnimation.currentTime - _BirdAnimation.duration
    end

    if (_BirdState == 'Playing') then
        if (_BirdBoost <= 0) then
            _BirdCurrentY = _BirdCurrentY + 2.6
        else
            _BirdBoost = _BirdBoost - 3.75
            _BirdCurrentY = _BirdCurrentY - 3
        end

        if (_BirdCurrentY < _BirdHeight) then
            _BirdCurrentY = _BirdHeight
        end

        if ((_BirdCurrentY + _BirdHeight) > (_Height - _Base:getHeight())) then
            _BirdFailAudio:play()
            _BirdState = 'Failed'
            _GameState = 'ShowResult'            
        end
    elseif (_BirdState == 'Failed') and ((_BirdCurrentY + _BirdHeight) < (_Height - _Base:getHeight())) then
        _BirdCurrentY = _BirdCurrentY + 7
    end

    _BirdAngleDeg = lerp(_BirdCurrentY, _BirdLastTouchY, _Height - _Base:getHeight(), -25, 90)
end

function Bird:boost()
    _BirdLastTouchY = _BirdCurrentY
    _BirdBoost = 50
    if (_BirdBoost > 120) then
        _BirdBoost = 120
    end
end

function Bird:getUpY()
    return _BirdCurrentY
end

function Bird:getDownY()
    return _BirdCurrentY + _BirdHeight
end

function Bird:getLeftX()
    return _Width / 2 - _BirdWidth / 2
end

function Bird:getRightX()
    return _Width / 2 + _BirdWidth / 2
end

-- Left up point.
function Bird:getLUPoint()
    local res = {}
    res[0] = self.getLeftX()
    res[1] = self.getUpY()

    return res
end

-- Left down point.
function Bird:getLDPoint()
    return rotatePoint(self.getLeftX(), self.getDownY(), self.getLeftX(), _BirdCurrentY, _BirdAngleDeg)
end

-- Right up point.
function Bird:getRUPoint()
    return rotatePoint(self.getRightX(), self.getUpY(), self.getLeftX(), _BirdCurrentY, _BirdAngleDeg)
end

-- Right down point.
function Bird:getRDPoint()
    return rotatePoint(self.getRightX(), self.getDownY(), self.getLeftX(), _BirdCurrentY, _BirdAngleDeg)
end

function Bird:draw()
    local spriteNum = math.floor(_BirdAnimation.currentTime / _BirdAnimation.duration * #_BirdAnimation.quads) + 1

    if (_BirdState == 'Failed') then
        spriteNum = 1
    end        

    drawSprite(_BirdAnimation.spriteSheet, _BirdAnimation.quads[spriteNum],
        _Width / 2 - _BirdWidth / 2,
        _BirdCurrentY,
        _BirdAngleDeg / 180.0 * math.pi)

    if (isDebugMode) then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(0, 0.7, 0, 0.5)
        love.graphics.push()

        love.graphics.translate(_Width / 2 - _BirdWidth / 2, _BirdCurrentY)
        love.graphics.rotate(_BirdAngleDeg * math.pi / 180.0)
        love.graphics.rectangle("fill", 0, 0, _BirdWidth, _BirdHeight)

        love.graphics.pop()

        love.graphics.setColor(0, 0, 0.7, 0.5)
        love.graphics.circle("fill", self.getLeftX(), self.getUpY(), 4)

        local ld = self:getLDPoint()
        love.graphics.circle("fill", ld[0], ld[1], 4)

        local rd = self:getRDPoint()
        love.graphics.circle("fill", rd[0], rd[1], 4)
        
        local ru = self:getRUPoint()
        love.graphics.circle("fill", ru[0], ru[1], 4)

        love.graphics.setColor(r, g, b, a)
    end
end