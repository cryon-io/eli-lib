local io = require"io"

local function execute(cmd) 
   f = io:popen(cmd)
   output = f:read"a*"
   exit, signal = f:close()
   return exit, signal, output 
end

return {
   execute = execute
}
