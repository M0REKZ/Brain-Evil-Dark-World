-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

KaizoStick = {}

function KaizoStick:new(x,y,z)
    local kaizoCube = {}
    setmetatable(kaizoCube, self)
    self.__index = self

    kaizoCube.body = MainLevel.world:newBoxCollider(x,y,z,1,1,1)
    kaizoCube.body:setTag("pickup")
    kaizoCube.is_checkpoint = true
    kaizoCube.checkpoint_number = 0

    return kaizoCube
end

function KaizoStick:preupdate(dt)
    self.body:setAngularVelocity(0,0,0)
    self.body:setOrientation(0, 0, 0, 0)
end

function KaizoStick:postupdate(dt)
    local x,y,z = self.body:getPosition()

    if y < MainLevel.death_line_y then
        self.marked_for_deletion = true
        return
    end
end

function KaizoStick:draw(pass)
    if not self.img then
        self.img = KaizoImage:new("entity_stick.png")
    end

    local x,y,z = self.body:getPosition()
    self.img:draw_billboard(pass,x,y,z,1.45)
end

function KaizoStick:handle_pickup(collector)
    KaizoSaveHandler.savedata.player_stick = 0
    collector.current_weapon = "stick"
    self.marked_for_deletion = true
end
