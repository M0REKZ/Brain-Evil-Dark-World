-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

local projection
local origprojection = lovr.math.newMat4()
local width, height

function Set2DPass(pass, setorno)
    if setorno then
        width, height = lovr.system.getWindowDimensions()
        projection = Mat4():orthographic(0, width, 0, height, -10, 10)
        origprojection = pass:getProjection(1, origprojection)
        pass:setViewPose(1, mat4():identity())
        pass:setProjection(1, projection)
        pass:setDepthTest()
    else
        
        pass:setProjection(1,origprojection)
        pass:setViewPose(1, mat4():lookAt(lovr.math.vec3(KaizoCamera.x, KaizoCamera.y, KaizoCamera.z), lovr.math.vec3(KaizoCamera.look_at_x, KaizoCamera.look_at_y, KaizoCamera.look_at_z)), true)
        pass:setDepthTest("gequal")
    end
end

function SetTextShader(pass)
    pass:setShader(TextShader)
end

function SetGameShader(pass)
    pass:setShader(GameShader)
    pass:send('lightColor', {1.0, 1.0, 1.0, 1.0})
    pass:send('lightPos', {2.0 * 100, 5.0 * 100, 0.0})
    pass:send('ambience', {1, 1, 1, 1.0})
    pass:send('specularStrength', 1.5)
    pass:send('metallic', 1.0)
end
