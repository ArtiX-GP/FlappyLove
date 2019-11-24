Tube = {}
Tube.__index = Tube

function Tube:create(x, red)
    local tube = {}
    setmetatable(tube, Tube)

    tube._TubePositionX = x

    tube._TubePositionY = math.random(25, _Height - 250)

    tube.isRed = red

    tube.hasBeenFinished = false

    return tube
end

function Tube:update()
    self._TubePositionX = self._TubePositionX - 2
    if (self._TubePositionX < -50) then
        table.remove(_Tubes, 0)
    end

    -- Проверка столкновения.

    local lu = _Bird:getLUPoint()
    local ld = _Bird:getLDPoint()
    local rd = _Bird:getRDPoint()
    local ru = _Bird:getRUPoint()

    if ((ru[0] >= (self._TubePositionX - _TubeDrawable:getWidth() + 2)) and ru[0] <= (self._TubePositionX - 2)) then
        if (ru[1] <= self._TubePositionY) or (rd[1] >= self._TubePositionY + _DistanceBetweenTubes) then
            _Bird:setState('Failed')
            _GameState = 'ShowResult'
        end
    elseif (lu[0] > self._TubePositionX) and not self.hasBeenFinished then
        self.hasBeenFinished = true
        _Scores = _Scores + 1
        _PointAudio:play()
    end

    if ((lu[0] <= (self._TubePositionX - 2)) and lu[0] >= (self._TubePositionX - _TubeDrawable:getWidth() + 2)) then
        if (lu[1] <= self._TubePositionY) or (ld[1] >= self._TubePositionY + _DistanceBetweenTubes) then
            _Bird:setState('Failed')
            _GameState = 'ShowResult'
        end
    end

    if ((ld[0] <= (self._TubePositionX - 2)) and ld[0] >= (self._TubePositionX - _TubeDrawable:getWidth() + 2)) then
        if (lu[1] <= self._TubePositionY) or (ld[1] >= self._TubePositionY + _DistanceBetweenTubes) then
            _Bird:setState('Failed')
            _GameState = 'ShowResult'
        end
    end

    if ((rd[0] <= (self._TubePositionX - 2)) and rd[0] >= (self._TubePositionX - _TubeDrawable:getWidth() + 2)) then
        if (ru[1] <= self._TubePositionY) or (rd[1] >= self._TubePositionY + _DistanceBetweenTubes) then
            _Bird:setState('Failed')
            _GameState = 'ShowResult'
        end
    end
    
end

function Tube:draw()
    local d
    if (self.isRed) then
        d = _TubeRedDrawable
    else
        d = _TubeDrawable
    end

    draw(d, self._TubePositionX, self._TubePositionY, math.pi)
    draw(d, self._TubePositionX - d:getWidth(), self._TubePositionY + _DistanceBetweenTubes)

    if (isDebugMode) then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(0.7, 0, 0, 0.5)
        love.graphics.rectangle("fill", self._TubePositionX - _TubeDrawable:getWidth() + 2, 0, _TubeDrawable:getWidth() - 4, self._TubePositionY)

        love.graphics.rectangle("fill", self._TubePositionX - _TubeDrawable:getWidth() + 2, self._TubePositionY + _DistanceBetweenTubes, _TubeDrawable:getWidth() - 4, _Height - self._TubePositionY)
        love.graphics.setColor(r, g, b, a)
    end
end