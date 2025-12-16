-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

KaizoImage = {}

function KaizoImage:new(imagePath, fullpath)
    local kaizoImage = {}
    setmetatable(kaizoImage, self)
    self.__index = self

    if not fullpath then
        imagePath = 'data/images/' .. imagePath
    end

    kaizoImage.imagePath = imagePath
    kaizoImage.texture = lovr.graphics.newTexture(imagePath)

    return kaizoImage
end

function KaizoImage:draw_billboard(pass, x, y, z, scale, xflip)
    local s = scale or 1
    --(KaizoCamera.anglex * -1 + math.pi/2,0,1,0)
    --((KaizoCamera.angley/2 + math.pi/4) * -1,0,0,1)
    --((KaizoCamera.angley/2 - math.pi/4) * -1,1,0,0)
    if xflip then
        local rxflip = quat(math.pi,0,1,0)
        
        pass:draw(self.texture, x, y, z, s, KaizoCamera.render_quat * rxflip)
    else
        pass:draw(self.texture, x, y, z, s, KaizoCamera.render_quat)
    end
end
