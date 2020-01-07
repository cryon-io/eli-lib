local function eli_init()
   local path = require"eli.path"
   local proc = require"eli.proc"
   local i_min = 0
   while arg[i_min] do
      i_min = i_min - 1
   end

   local function try_identify_interpreter(interpreter)
      if path.default_sep() == "/" then
         local io = require "io"
         local f = io.popen("which " .. interpreter)
         local path = f:read("a*")
         if path ~= nil then
            path = path:gsub("%s*", "")
         end
         exit = f:close()
         if exit == 0 then
            return path
         end
      else
         path = requore "os".getenv "PATH"
         if path then
            for subpath in path:gmatch("([^;]+)") do
               if path.file(subpath) == interpreter then
                  return subpath
               end
            end
         end
      end
   end

   interpreter = arg[i_min + 1]
   if not interpreter:match(path.default_sep()) then
      local identified, _interpreter = pcall(try_identify_interpreter, interpreter)
      if identified then
         interpreter = _interpreter
      end
   elseif not path.isabs(interpreter) and proc.EPROC then
      interpreter = path.abs(interpreter, proc.cwd())
   end

   if i_min == -1 then -- we are running without script (interactive mode)
      APP_ROOT = nil
   else
      if proc.EPROC then
         APP_ROOT_SCRIPT = path.abs(arg[0], lfs.cwd())
      else
         APP_ROOT_SCRIPT = arg[0]
      end
      APP_ROOT = path.dir(APP_ROOT_SCRIPT)
   end
   ELI_LIB_VERSION = "0.3.0"
end

eli_init()
-- cleanup init
eli_init = nil
