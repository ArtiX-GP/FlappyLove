-- function draw(img)
--     if (img) then
--         love.graphics.draw(img, 0, 0, 0, 1, 1, 0, 0) 
--     end
-- end

function draw(img, x, y, r)
    if (img) then
        love.graphics.draw(img, x, y, r, 1, 1, 0, 0) 
    end
end

function drawSprite(img, quad, x, y, r)
    if (img) then
        love.graphics.draw(img, quad, x, y, r, 1, 1, 0, 0) 
    end
end

function createAnimation(img, width, height, duration)
    local animation = {}
    animation.spriteSheet = img;
    animation.quads = {};
 
    for y = 0, img:getHeight() - height, height do
        for x = 0, img:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, img:getDimensions()))
        end
    end
 
    animation.duration = duration or 1
    animation.currentTime = 0
 
    return animation
end

function lerp(value, imin, imax, omin, omax)
    local scale = (omax - omin) / (imax - imin)
    local res = omin + (value - imin) * scale
    if (res < omin) then
        return omin
    elseif (res > omax) then
        return omax
    end
    return res
end

function rotatePoint(x, y, pivotX, pivotY, angleInDeg) 
    local a = angleInDeg / 180.0 * math.pi
    local res = {}

    res[0] = math.cos(a) * (x - pivotX) - math.sin(a) * (y - pivotY) + pivotX
    res[1] = math.sin(a) * (x - pivotX) + math.cos(a) * (y - pivotY) + pivotY

    return res
end