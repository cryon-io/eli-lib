local lfs = require"lfs"
local zip = require"lzip"
local path = require"eli.path"
local mkdirp = require"eli.fs".mkdirp
local separator = require"eli.path".default_sep()
local generate_safe_functions = require"eli.util".generate_safe_functions

local function extract(source, destination, ignoreRootLevelDir)
   assert(lfs.attributes(destination, "mode") == "directory", "Destination not found or is not a directory: " .. destination)

   local zip_arch, err = zip.open(source, zip.CHECKCONS)
   assert(zip_arch ~= nil, err)

   local ignoreDir = ''
   if ignoreRootLevelDir then
      -- check whether we have all files in root same dir
      local stat = zip_arch:stat(1)
      local rootDir = stat.name:match('^.-/')
      for i = 2, #zip_arch do
         stat = zip_arch:stat(i)
         if not stat.name:match('^' .. rootDir) then
            break
         end
      end
      ignoreDir = rootDir
   end
   local il = #ignoreDir + 1 -- ignore length

   for i = 1, #zip_arch do
      local stat = zip_arch:stat(i)
      local targetPath = path.combine(destination, stat.name:sub(il))
      if stat.name:sub(-#'/') == '/' then
          -- directory
          if lfs.attributes(targetPath) == nil then
             mkdirp(targetPath)
          end
      else
         local comprimedFile = zip_arch:open(i)
         local dir = path.dir(targetPath)
         if lfs.attributes(dir) == nil then
            mkdirp(dir)
         end
         local b = 0
         local f = io.open (targetPath, 'w+b')
         local chunkSize = 2^13 -- 8K
         while b < stat.size do
            local bytes = comprimedFile:read(math.min(chunkSize, stat.size - b))
            f:write(bytes)
            b = b + math.min(chunkSize, stat.size - b)
         end
         f:close()
         if separator == '/' then
            -- unix permissions
            local attributes = (zip_arch:get_external_attributes(i) / 2 ^ 16)
            local permissions = string.format("%o", attributes):sub(-3)
            if attributes ~= 0 then
               os.execute("chmod " .. permissions .. " " .. targetPath .. " > /dev/nul")
            end
         end
     end
   end
   zip_arch:close()
end

return generate_safe_functions({
   extract = extract
})

