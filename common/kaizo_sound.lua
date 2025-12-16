-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

KaizoSound = {}

function KaizoSound:new(soundPath, isMusic, fullpath)
    local kaizoSound = {}
    setmetatable(kaizoSound, self)
    self.__index = self

    if not fullpath then
        soundPath = 'data/sound/' .. soundPath
    end

    kaizoSound.soundPath = soundPath
    if isMusic then
        kaizoSound.sound = lovr.audio.newSource(soundPath, {pitchable = false})
        kaizoSound.sound:setLooping(true)
    else
        kaizoSound.sound = lovr.audio.newSource(soundPath, {decode = true, pitchable = false})
    end

    return kaizoSound
end

function KaizoSound:play()
    self.sound:play()
end

function KaizoSound:stop()
    self.sound:stop()
end

function KaizoSound:pause()
    self.sound:pause()
end
