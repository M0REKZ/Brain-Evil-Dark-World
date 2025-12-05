
local json = require("external.dkjson")

KaizoJSONHandler = {}

function KaizoJSONHandler:ToJSON(val)
    return json.encode(val)
end

function KaizoJSONHandler:FromJSON(str)
    return json.decode(str)
end
