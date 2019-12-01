local io = require "io"
local dir = require "eli.path".dir
local combine = require "eli.path".combine
local generate_safe_functions = require "eli.util".generate_safe_functions
local lfsLoaded, lfs = pcall(require, "lfs")
local hash = require "hash"

local function check_lfs_available(operation)
   if not lfsLoaded then
      if operation ~= nil and operation ~= "" then
         error("LFS not available! Operation " .. operation .. " failed!")
      else
         error("LFS not available!")
      end
   end
end

local function read_file(src)
   local f = assert(io.open(src, "r"), "No such a file or directory - " .. src)
   local result = f:read("a*")
   f:close()
   return result
end

local function write_file(dst, content)
   local f = assert(io.open(dst, "w"), "No such a file or directory - " .. dst)
   f:write(content)
   f:close()
end

local function copy_file(src, dst)
   assert(src ~= dst)
   local srcf = assert(io.open(src, "r"), "No such a file or directory - " .. src)
   local dstf = assert(io.open(dst, "w"), "Failed to open file for write - " .. dst)

   local size = 2 ^ 12 -- 4K
   while true do
      local block = srcf:read(size)
      if not block then
         break
      end
      dstf:write(block)
   end
end

local function mkdirp(dst)
   check_lfs_available("mkdirp")
   local parent = dir(dst)
   if parent ~= nil then
      mkdirp(parent)
   end
   lfs.mkdir(dst)
end

local function delete(dst, recurse)
   check_lfs_available("delete")
   if lfs.attributes(dst) == nil then
      return
   end
   if lfs.attributes(dst, "mode") == "file" then
      os.remove(dst)
   end
   if recurse then
      for o in lfs.dir(dst) do
         local fullPath = combine(dst, o)
         if o ~= "." and o ~= ".." then
            if lfs.attributes(fullPath, "mode") == "file" then
               os.remove(fullPath)
            elseif lfs.attributes(fullPath, "mode") == "directory" then
               delete(fullPath, recurse)
            end
         end
      end
   end
   lfs.rmdir(dst)
end

local function move(src, dst)
   return require "os".rename(src, dst)
end

local function exists(path)
   check_lfs_available("exists")
   if lfs.attributes(path) then
      return true
   else
      return false
   end
end

local function mkdir(...)
   check_lfs_available("mkdir")
   lfs.mkdir(...)
end

local function lfs_available()
   return lfsLoaded
end

local function hash_file(src, options)
   if type(options) ~= "table" then
      options = {}
   end
   if options.type ~= "sha512" then
      options.type = "sha256"
   end
   local srcf = assert(io.open(src, "r"), "No such a file or directory - " .. src)
   local size = 2 ^ 12 -- 4K

   if options.type == "sha256" then
      local ctx = hash.sha256_init()
      while true do
         local block = srcf:read(size)
         if not block then
            break
         end
         hash.sha256_update(ctx, block)
      end
      return hash.sha256_finish(ctx, options.hex)
   else
      local ctx = hash.sha512_init()
      while true do
         local block = srcf:read(size)
         if not block then
            break
         end
         hash.sha512_update(ctx, block)
      end
      return hash.sha512_finish(ctx, options.hex)
   end
end

return generate_safe_functions(
   {
      write_file = write_file,
      read_file = read_file,
      copy_file = copy_file,
      mkdir = mkdir,
      mkdirp = mkdirp,
      delete = delete,
      exists = exists,
      move = move,
      lfs_available = lfs_available,
      hash_file = hash_file
   }
)
