local function eli_init() 
   local path = require"eli.path"
   local lfs = require"lfs"
   local i_min = 0
   while arg[ i_min ] do i_min = i_min - 1 end

   interpreter = arg[i_min + 1]
   if not interpreter:match(path.default_sep()) then 
      if path.default_sep() == '/' then
         local io = require"io"
         local f = io.popen("which " .. interpreter)
         local path = f:read("a*")
         if path ~= nil then 
            path = path:gsub("%s*", "")
         end
         exit = f:close()
         if exit == 0 then 
            interpreter = path
         end
      else 
         path = requore"os".getenv"PATH"
         if path then
            for subpath in path:gmatch('([^;]+)') do
               if path.file(subpath) == interpreter then 
                  interpreter = subpath
                  break
               end
            end
         end
      end
   elseif not path.isabs(interpreter) then
      interpreter = path.abs(interpreter, require"lfs".currentdir())
   end

   if i_min == -1 then -- we are running without script (interactive mode)
      appRoot = nil 
   else 
      appRootScript = path.abs(arg[0], require"lfs".currentdir())
      appRoot = path.dir(appRootScript)
   end
end 

eli_init()
-- cleanup init
eli_init = nil
