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
    if not lovr.audio then
        print("WARNING: Audio module not available, sound " .. soundPath .. " will not be loaded.")
        return kaizoSound
    end
    if isMusic then
        kaizoSound.sound = lovr.audio.newSource(soundPath, {pitchable = false})
        kaizoSound.sound:setLooping(true)
    else
        kaizoSound.sound = lovr.audio.newSource(soundPath, {decode = true, pitchable = false})
    end

    return kaizoSound
end

function KaizoSound:play()
    if self.sound then
        self.sound:play()
    end
end

function KaizoSound:stop()
    if self.sound then
        self.sound:stop()
    end
end

function KaizoSound:pause()
    if self.sound then
        self.sound:pause()
    end
end
