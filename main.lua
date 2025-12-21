-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

require "common.kaizo_ffi_binds"
require "common.kaizo_camera"
require "common.kaizo_image"
require "common.kaizo_sound"
require "common.kaizo_level"
require "common.objects.kaizo_cube"
require "common.objects.kaizo_map"
require "common.objects.kaizo_player"
require "common.objects.brainevil_killerbot"
require "common.objects.brainevil_drone"
require "common.objects.brainevil_victim"
require "common.objects.kaizo_stick"
require "handler.kaizo_input_handler"
require "handler.kaizo_pause_handler"
require "handler.kaizo_movie_handler"
require "levels.bedw.brainevil_level_loader"

SetMouseGrabbed(true)
FPS = 60

IsFullscreen = false
local start_fullscreen = false
local set_start_fullscreen = false

local sampler = lovr.graphics.newSampler({filter = {"nearest", "nearest", "nearest"}})

local vertex = [[
    vec4 lovrmain()
    {
        return Projection * View * Transform * VertexPosition;
    }
]]

local fragment = [[
    Constants {
      vec4 ambience;
      vec4 lightColor;
      vec3 lightPos;
      float specularStrength;
      int metallic;
    };

    vec4 lovrmain()
    {
        //diffuse
        vec3 norm = normalize(Normal);
        vec3 lightDir = normalize(lightPos - PositionWorld);
        float diff = max(dot(norm, lightDir), 0.0);
        vec4 diffuse = diff * lightColor;

        //specular
        vec3 viewDir = normalize(CameraPositionWorld - PositionWorld);
        vec3 reflectDir = reflect(-lightDir, norm);
        float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
        vec4 specular = specularStrength * spec * lightColor;

        vec4 baseColor = Color * getPixel(ColorTexture, UV);
        return baseColor * (ambience + diffuse + specular);
    }
]]

local textfragment = [[
    vec4 lovrmain()
    {
        vec4 baseColor = Color * getPixel(ColorTexture, UV);
        return vec4(1,1,1,baseColor.a);
    }
]]

GameShader = lovr.graphics.newShader(vertex,fragment, {})
TextShader = lovr.graphics.newShader(vertex,textfragment,{})

GameFont = lovr.graphics.newFont("data/fonts/Snowstorm.otf",500)
function lovr.load()
    KaizoSaveHandler:Init()
    if lovr.audio then
        lovr.audio.setVolume(KaizoSaveHandler.config.volume)
    else
        print("WARNING: Audio module could not be initialized!")
    end
    KaizoPauseHandler:init()
    lovr.graphics.setBackgroundColor(0x120730)
    BrainEvilLevelLoader:LoadMenuLevel()
    time = 0
    timestep = 1 / FPS -- 60Hz

    KaizoMovieHandler:PlayMovie("menu")
end


function lovr.update(dt)
    if not set_start_fullscreen and start_fullscreen then --look at the end of this function for explanation
        SetFullscreen()
        set_start_fullscreen = true
    end

    if KaizoMovieHandler.playing_movie then
        if lovr.system.isWindowVisible() and lovr.system.isWindowOpen() then
            time = time + dt
            while time >= timestep do
                KaizoInputHandler:handle_input()
                KaizoMovieHandler:UpdateMovie(dt)
                time = time - timestep
            end
        end
    else

        time = time + dt
        while time >= timestep do
            KaizoInputHandler:handle_input()

            if not KaizoPauseHandler.waiting_for_release_key and KaizoInputHandler.pause then
                if KaizoPauseHandler.active then
                    KaizoPauseHandler.active = false
                else
                    KaizoPauseHandler.active = true
                end
                KaizoPauseHandler.waiting_for_release_key = true
            elseif not KaizoInputHandler.pause then
                KaizoPauseHandler.waiting_for_release_key = false
            end
            if KaizoPauseHandler:update() then
                time = time - timestep
                return
            end

            MainLevel:update(timestep)
            if MainLevel.targets and #MainLevel.targets == 0 then
                BrainEvilLevelLoader:HandleLevelNoMoreTargets()
            end
            time = time - timestep
        end

        local alpha = time / timestep
        MainLevel:interpolate(alpha)
    end

    -- doing things this way because if i put fullscreen on the
    -- first tick the game gets stretched graphicaly, which is not wanted
    if not IsFullscreen and KaizoSaveHandler.config.fullscreen then
        start_fullscreen = true
    end

    lovr.timer.sleep(1/(FPS+10)) --to avoid high cpu usage
end

function lovr.mousemoved(x, y, dx, dy)

    if not MainLevel.is_menu_level and KaizoPauseHandler.active then
        return
    end

    --dont do camera jumping
    if x == dx or y == dy then
        return
    end

    --dont do camera jumping x2
    if dx > 10 then
        dx = 10
    elseif dx < -10 then
        dx = -10
    elseif dy > 10 then
        dy = 10
    elseif dy < -10 then
        dy = -10
    end
    
    if MainLevel.camera_following_object then
        KaizoCamera.anglex = KaizoCamera.anglex + dx * (math.pi/180)
        if KaizoSaveHandler.config.invert_mouse then
            KaizoCamera.angley = KaizoCamera.angley - dy * (math.pi/180)
        else
            KaizoCamera.angley = KaizoCamera.angley + dy * (math.pi/180)
        end

        if KaizoCamera.anglex > math.pi * 2 then
            KaizoCamera.anglex = math.fmod(KaizoCamera.anglex,math.pi * 2)
        elseif KaizoCamera.anglex < math.pi*2 then
            KaizoCamera.anglex = math.fmod(KaizoCamera.anglex,math.pi * 2)
        end

        if KaizoCamera.angley > math.pi then
            KaizoCamera.angley = math.pi
        elseif KaizoCamera.angley < 0 then
            KaizoCamera.angley = 0
        end
    end
end

function lovr.draw(pass)
    

    pass:setAlphaToCoverage(true)

    --lighting
    SetGameShader(pass)
    pass:setSampler(sampler)
    pass:setFont(GameFont)

    if KaizoMovieHandler.playing_movie then
        KaizoMovieHandler:DrawMovie(pass)
        return
    end

    if MainLevel.camera_following_object then
        local x, y, z = MainLevel.camera_following_object.body:getPosition()

        if KaizoSaveHandler.config.first_person then
            KaizoCamera.look_at_x = x - (math.cos(KaizoCamera.anglex)* 2)
            KaizoCamera.look_at_z = z - (math.sin(KaizoCamera.anglex)* 2)
            KaizoCamera.look_at_y = (y + 0.5) - (math.cos(KaizoCamera.angley)* 2)
            KaizoCamera.x, KaizoCamera.y, KaizoCamera.z = x,y + 0.5,z
        else
            KaizoCamera.x = x + KaizoCamera.away * (math.cos(KaizoCamera.anglex)* 2)
            KaizoCamera.z = z + KaizoCamera.away * (math.sin(KaizoCamera.anglex)* 2)
            KaizoCamera.y = y + 0.5 + KaizoCamera.away * (math.cos(KaizoCamera.angley)* 2)
            KaizoCamera.look_at_x, KaizoCamera.look_at_y, KaizoCamera.look_at_z = x,y,z
        end

        local collide, cx, cy, cz
        collide, _, cx, cy, cz = MainLevel.world:raycast(x, y, z, KaizoCamera.x, KaizoCamera.y, KaizoCamera.z, "solid")

        if collide then
            KaizoCamera.x = cx - 0.1 * (math.cos(KaizoCamera.anglex)* 2)
            KaizoCamera.z = cz - 0.1 * (math.sin(KaizoCamera.anglex)* 2)
            KaizoCamera.y = cy - 0.1 * (math.cos(KaizoCamera.angley)* 2)
        end

        KaizoCamera.render_quat:setEuler((KaizoCamera.angley/2 - math.pi/4), (KaizoCamera.anglex * -1 + math.pi/2), 0)
    end
    pass:setViewPose(1, mat4():lookAt(lovr.math.vec3(KaizoCamera.x, KaizoCamera.y, KaizoCamera.z), lovr.math.vec3(KaizoCamera.look_at_x, KaizoCamera.look_at_y, KaizoCamera.look_at_z)), true)
    MainLevel:draw(pass)

    KaizoPauseHandler:draw(pass)
end

function lovr.keypressed(key, scancode, r)
    KaizoInputHandler.last_key_pressed = key
end
