-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

BrainEvilVictim = {}

function BrainEvilVictim:new(x,y,z)
    local kaizoCube = {}
    setmetatable(kaizoCube, self)
    self.__index = self

    kaizoCube.body = MainLevel.world:newBoxCollider(x,y,z,1,1,1)
    kaizoCube.body:setTag("pickup")
    kaizoCube.invisible = false
    kaizoCube.boy = math.random(2)
    kaizoCube.img = nil

    return kaizoCube
end

function BrainEvilVictim:preupdate(dt)
    self.body:setAngularVelocity(0,0,0)
    self.body:setOrientation(0, 0, 0, 0)
end

function BrainEvilVictim:postupdate(dt)
    local x,y,z = self.body:getPosition()

    if y < MainLevel.death_line_y then
        self.marked_for_deletion = true
        return
    end
end

function BrainEvilVictim:draw(pass)
    if not self.img then
        if self.boy == 1 then
            self.img = KaizoImage:new("entity_victim2.png")
        else
            self.img = KaizoImage:new("entity_victim.png")
        end
    end

    local x,y,z = self.body:getPosition()
    self.img:draw_billboard(pass,x,y+0.225,z,1.45)
end

function BrainEvilVictim:handle_pickup(collector)
    self.marked_for_deletion = true
end

