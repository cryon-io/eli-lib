local lfsLoaded, lfs = pcall(require, "lfs")
local zip = require "lzip"
local path = require "eli.path"
local separator = require "eli.path".default_sep()
local generate_safe_functions = require "eli.util".generate_safe_functions

local function extract(source, destination, options)
   if lfsLoaded then
      assert(
         lfs.attributes(destination, "mode") == "directory",
         "Destination not found or is not a directory: " .. destination
      )
   end

   local mkdirp = lfsLoaded and require "eli.fs".mkdirp

   local ignoreRootLevelDir = false
   local transform_path = nil
   if type(options) == "table" then
      ignoreRootLevelDir = options.ignoreRootLevelDir
      transform_path = options.transform_path
      if type(options.mkdirp) == "function" then
         mkdirp = options.mkdirp
      end
   elseif type(options) == "boolean" then
      ignoreRootLevelDir = options
   end

   local zip_arch, err = zip.open(source, zip.CHECKCONS)
   assert(zip_arch ~= nil, err)

   local ignoreDir = ""
   if ignoreRootLevelDir then
      -- check whether we have all files in root same dir
      local stat = zip_arch:stat(1)
      local rootDir = stat.name:match("^.-/")
      for i = 2, #zip_arch do
         stat = zip_arch:stat(i)
         if not stat.name:match("^" .. rootDir) then
            break
         end
      end
      ignoreDir = rootDir
   end
   local il = #ignoreDir + 1 -- ignore length

   for i = 1, #zip_arch do
      local stat = zip_arch:stat(i)

      local targetPath = path.filename(stat.name) -- by default we assume that mkdir is nor supported and we cannot create directories

      if type(transform_path) == "function" then -- if supplied transform with transform functions
         targetPath = transform_path(stat.name)
      elseif mkdirp then --mkdir supported we can use path as is :)
         targetPath = path.combine(destination, stat.name:sub(il))
      end

      if stat.name:sub(-(#"/")) == "/" then
         -- directory
         if type(mkdirp) == "function" and lfs.attributes(targetPath) == nil then
            mkdirp(targetPath)
         end
      else
         local comprimedFile = zip_arch:open(i)
         local dir = path.dir(targetPath)
         if type(mkdirp) == "function" and lfs.attributes(dir) == nil then
            mkdirp(dir)
         end
         local b = 0
         local f = io.open(targetPath, "w+b")
         local chunkSize = 2 ^ 13 -- 8K
         while b < stat.size do
            local bytes = comprimedFile:read(math.min(chunkSize, stat.size - b))
            f:write(bytes)
            b = b + math.min(chunkSize, stat.size - b)
         end
         f:close()
         if separator == "/" then
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

return generate_safe_functions(
   {
      extract = extract
   }
)
