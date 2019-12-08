local lfsLoaded, lfs = pcall(require, "lfs")
local zip = require "lzip"
local path = require "eli.path"
local separator = require "eli.path".default_sep()
local util = require "eli.util"
local generate_safe_functions = util.generate_safe_functions
local escape_magic_characters = util.escape_magic_characters

local function get_root_dir(zipArch)
   -- check whether we have all files in same dir
   local stat = zipArch:stat(1)
   local rootDir = stat.name:match("^.-/")
   for i = 2, #zipArch do
      stat = zipArch:stat(i)
      if not stat.name:match("^" .. escape_magic_characters(rootDir)) then
         return ""
      end
   end
   return rootDir
end

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
   local filter = nil
   if type(options) == "table" then
      ignoreRootLevelDir = options.ignoreRootLevelDir
      transform_path = options.transform_path
      filter = options.filter
      if type(options.mkdirp) == "function" then
         mkdirp = options.mkdirp
      end
   elseif type(options) == "boolean" then
      ignoreRootLevelDir = options
   end

   local zipArch, err = zip.open(source, zip.CHECKCONS)
   assert(zipArch ~= nil, err)

   local ignoreDir = ""
   if ignoreRootLevelDir then
      ignoreDir = get_root_dir(zipArch)
   end
   local il = #ignoreDir + 1 -- ignore length

   for i = 1, #zipArch do
      local stat = zipArch:stat(i)

      if type(filter) == 'function' and not filter(stat.name) then
         goto files_loop
      end
         
      local targetPath = path.filename(stat.name) -- by default we assume that mkdir is nor supported and we cannot create directories

      if type(transform_path) == "function" then -- if supplied transform with transform functions
         targetPath = transform_path(stat.name)
      elseif type(mkdirp) == 'function' then --mkdir supported we can use path as is :)
         targetPath = path.combine(destination, stat.name:sub(il))
      end

      if stat.name:sub(-(#"/")) == "/" then
         -- directory
         if type(mkdirp) == "function" then
            mkdirp(targetPath)
         end
      else
         local comprimedFile = zipArch:open(i)
         local dir = path.dir(targetPath)
         if type(mkdirp) == "function" then
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
            local attributes = (zipArch:get_external_attributes(i) / 2 ^ 16)
            local permissions = string.format("%o", attributes):sub(-3)
            if attributes ~= 0 then
               os.execute("chmod " .. permissions .. " " .. targetPath .. " > /dev/nul")
            end
         end
      end
      ::files_loop::
   end
   zipArch:close()
end

local function extract_file(source, file, destination, options)
   if type(destination) == 'table' and options == nil then 
      options = destination
      destination = file
   end

   if lfsLoaded then
      assert(
         lfs.attributes(destination, "mode") ~= "directory",
         "Destination is a directory: " .. destination
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

   local zipArch, err = zip.open(source, zip.CHECKCONS)
   assert(zipArch ~= nil, err)

   local ignoreDir = ""
   if ignoreRootLevelDir then
      ignoreDir = get_root_dir(zipArch)
   end
   local il = #ignoreDir + 1 -- ignore length

   for i = 1, #zipArch do
      local stat = zipArch:stat(i)

      local targetPath = path.filename(stat.name) -- by default we assume that mkdir is nor supported and we cannot create directories

      if type(transform_path) == "function" then -- if supplied transform with transform functions
         targetPath = transform_path(stat.name)
      elseif type(mkdirp) == 'function' then --mkdir supported we can use path as is :)
         targetPath = destination
      end

      if file == stat.name:sub(il) then 
         local comprimedFile = zipArch:open(i)
         local dir = path.dir(targetPath)
         if type(mkdirp) == "function" then
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
            local attributes = (zipArch:get_external_attributes(i) / 2 ^ 16)
            local permissions = string.format("%o", attributes):sub(-3)
            if attributes ~= 0 then
               os.execute("chmod " .. permissions .. " " .. targetPath .. " > /dev/nul")
            end
         end
      end
   end
   zipArch:close()
end

local function extract_string(source, file, options)
   local ignoreRootLevelDir = false
   if type(options) == "table" then
      ignoreRootLevelDir = options.ignoreRootLevelDir
   elseif type(options) == "boolean" then
      ignoreRootLevelDir = options
   end

   local zipArch, err = zip.open(source, zip.CHECKCONS)
   assert(zipArch ~= nil, err)

   local ignoreDir = ""
   if ignoreRootLevelDir then
      ignoreDir = get_root_dir(zipArch)
   end
   local il = #ignoreDir + 1 -- ignore length

   for i = 1, #zipArch do
      local stat = zipArch:stat(i)

      if file == stat.name:sub(il) then 
         local comprimedFile = zipArch:open(i)
        
         local result = ""
         local b = 0
         local chunkSize = 2 ^ 13 -- 8K
         while b < stat.size do
            local bytes = comprimedFile:read(math.min(chunkSize, stat.size - b))
            result = result .. bytes
            b = b + math.min(chunkSize, stat.size - b)
         end
         zipArch:close()
         return result
      end
   end
   zipArch:close()
   return nil
end

local function get_files(source, options)
   local ignoreRootLevelDir = false
   local transform_path = nil
   if type(options) == "table" then
       ignoreRootLevelDir = options.ignoreRootLevelDir
       transform_path = options.transform_path
   elseif type(options) == "boolean" then
       ignoreRootLevelDir = options
   end

   local zipArch, err = zip.open(source, zip.CHECKCONS)
   assert(zipArch ~= nil, err)

   local ignoreDir = ""
   if ignoreRootLevelDir then
      ignoreDir = get_root_dir(zipArch)
   end
   local il = #ignoreDir + 1 -- ignore length

   local files = {}
   for i = 1, #zipArch do
       local stat = zipArch:stat(i)
       
       local targetPath = stat.name:sub(il)
       if type(transform_path) == "function" then -- if supplied transform with transform functions
           targetPath = transform_path(stat.name)
       end
       table.insert(files, stat.name:sub(il))
   end
   zipArch:close()
   return files
end


return generate_safe_functions(
   {
      extract = extract,
      extract_file = extract_file,
      extract_string = extract_string
      get_files = get_files
   }
)
