
KaizoModel = {}

function KaizoModel:new(model_path, fullpath)
    local kaizoModel = {}
    setmetatable(kaizoModel, self)
    self.__index = self

    if not fullpath then
        model_path = 'data/models/' .. model_path
    end

    kaizoModel.modelPath = model_path
    kaizoModel.model = lovr.graphics.newModel(model_path)

    return kaizoModel
end
