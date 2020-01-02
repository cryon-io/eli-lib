local io = require"io"
local generate_safe_functions = require"eli.util".generate_safe_functions

local function execute_get_output(cmd) 
   f = io.popen(cmd)
   output = f:read"a*"
   success, exit, code = f:close()
   return success, exit, code, output
end

return generate_safe_functions({
   execute_get_output = execute_get_output
})
