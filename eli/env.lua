local os = require"os"
local eenvLoaded, eenv = pcall(require, "eli.env.extra")

local util = require"eli.util"
local generate_safe_functions = util.generate_safe_functions
local merge_tables = util.merge_tables

local env = {
    get_env = os.getenv,
    EENV = eenvLoaded
}

if not eenvLoaded then 
    return generate_safe_functions(env)
end

return generate_safe_functions(merge_tables(env, eenv))