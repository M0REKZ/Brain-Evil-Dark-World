-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

require "common.kaizo_model"

KaizoMap = {}

function KaizoMap:new(model_path, x,y,z, game, level)
    local kaizoMap = {}
    setmetatable(kaizoMap, self)
    self.__index = self

    if game and level then
        kaizoMap.model = KaizoModel:new("levels/"..game.."/"..level.."/"..model_path, true)
    elseif game or level then
        error("must specify game and level")
    else
        kaizoMap.model = KaizoModel:new(model_path)
    end
    
    kaizoMap.body = MainLevel.world:newMeshCollider(kaizoMap.model.model)
    kaizoMap.body:setPosition(x,y,z)
    kaizoMap.body:setTag("solid")
    kaizoMap.body:setGravityScale(0)
    kaizoMap.body:setKinematic(true)
    kaizoMap.body:setFriction(1)

    kaizoMap.always_awake = true

    kaizoMap.img = nil

    return kaizoMap
end

function KaizoMap:preupdate(dt)
    
end

function KaizoMap:postupdate(dt)
    
end

function KaizoMap:draw(pass)

    local x,y,z = self.body:getPosition()

    if self.img then
        pass:setMaterial(self.img.texture)
    end
    
    pass:draw(self.model.model, x, y, z)

    if self.img then
        pass:setMaterial()
    end

end
