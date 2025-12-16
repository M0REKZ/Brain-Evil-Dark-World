-- Brain Evil: Dark World (c) Copyright Benjamín Gajardo All rights reserved
-- See license.txt at the root of the software directory for the license

local json = require("external.dkjson")

KaizoJSONHandler = {}

function KaizoJSONHandler:ToJSON(val)
    return json.encode(val)
end

function KaizoJSONHandler:FromJSON(str)
    return json.decode(str)
end
