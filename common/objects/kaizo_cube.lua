
KaizoCube = {}

function KaizoCube:new(x,y,z,sx,sy,sz)
    local kaizoCube = {}
    setmetatable(kaizoCube, self)
    self.__index = self

    kaizoCube.body = MainLevel.world:newBoxCollider(x,y,z,sx,sy,sz)
    kaizoCube.body:setTag("solid")
    kaizoCube.sx = sx or 1
    kaizoCube.sy = sy or 1
    kaizoCube.sz = sz or 1
    kaizoCube.invisible = false
    kaizoCube.img = nil

    return kaizoCube
end

function KaizoCube:preupdate(dt)
    
end

function KaizoCube:postupdate(dt)
    local x,y,z = self.body:getPosition()

    if y < MainLevel.death_line_y then
        self.marked_for_deletion = true
        return
    end
end

function KaizoCube:draw(pass)

    if self.img then
        pass:setMaterial(self.img.texture)
    end

    local x,y,z = self.body:getPosition()
    local angle, ax, ay, az = self.body:getOrientation()
    pass:box(x,y,z, self.sx, self.sy, self.sz, angle, ax, ay, az)

    if self.img then
        pass:setMaterial()
    end

end
