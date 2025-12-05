

KaizoMovieHandler = {}
KaizoMovieHandler.playing_movie = false
KaizoMovieHandler.movie_name = nil
KaizoMovieHandler.img = nil
KaizoMovieHandler.sound = nil
KaizoMovieHandler.music = nil
KaizoMovieHandler.movie_json = nil
KaizoMovieHandler.number = 1

function KaizoMovieHandler:PlayMovie(movie_name)
    if MainLevel.music then
        MainLevel.music:pause()
    end
    self.movie_name = movie_name
    self.playing_movie = true
    local moviejson = lovr.filesystem.read("data/movies/"..movie_name.."/movie.json")
    if not moviejson then
        error("ERROR: movie not found!")
    end
    self.movie_json = KaizoJSONHandler:FromJSON(moviejson)
    self:GoToScene(1)
end

function KaizoMovieHandler:UpdateMovie(dt)
    self.ticks = self.ticks - 1
    if self.ticks <= 0 then
        if not self:GoToScene(self.number + 1) then
            self.number = self.number + 1
        end
        return
    end
end

function KaizoMovieHandler:GoToScene(num)
    self:ResetScene()

    if not self.movie_json.images[num] then --finish movie
        self:Reset()
        if MainLevel.music then
            MainLevel.music:play()
        end
        return true
    end
    
    self.img = KaizoImage:new("data/movies/"..self.movie_name.."/"..self.movie_json.images[num], true)
    self.ticks = self.movie_json.seconds[num] * FPS
    if self.movie_json.sounds[num] then
        if self.sound then
            self.sound:stop()
        end
        self.sound = nil
        self.sound = KaizoSound:new("data/movies/"..self.movie_name.."/"..self.movie_json.sounds[num],false,true)
        self.sound:play()
    end
    if self.movie_json.musics[num] then
        if self.music then
            self.music:stop()
        end
        self.music = nil
        self.music = KaizoSound:new("data/movies/"..self.movie_name.."/"..self.movie_json.musics[num],true,true)
        self.music:play()
    end

    return false
end

function KaizoMovieHandler:DrawMovie(pass)
    Set2DPass(pass, true)

    local width, height = lovr.system.getWindowDimensions()

    pass:setMaterial(self.img.texture)
    pass:plane(width/2, height/2, 0, width, -height)
    pass:setMaterial()

    Set2DPass(pass, false)
end

function KaizoMovieHandler:Reset()
    self.movie_name = nil
    self.playing_movie = false
    self.sound = nil
    self.music = nil
    self:ResetScene()
    self.movie_json = nil
    self.number = 1
end

function KaizoMovieHandler:ResetScene()
    self.img = nil
    self.ticks = 0
end
