local io = require"io"
local generate_safe_functions = require"eli.util".generate_safe_functions

local function execute(cmd) 
   f = io:popen(cmd)
   output = f:read"a*"
   exit, signal = f:close()
   return exit, signal, output 
end

return generate_safe_functions({
   execute = execute
})
