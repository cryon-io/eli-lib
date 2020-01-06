local io = require "io"
local dir = require "eli.path".dir
local combine = require "eli.path".combine
local util = require"eli.util"
local generate_safe_functions = util.generate_safe_functions
local merge_tables = util.merge_tables
local efsLoaded, efs = pcall(require, "eli.fs.extra")
local hash = require "lmbed_hash"

local function check_efs_available(operation)
   if not efsLoaded then
      if operation ~= nil and operation ~= "" then
         error("Extra fs api not available! Operation " .. operation .. " failed!")
      else
         error("Extra fs api not available!")
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
   check_efs_available("mkdirp")
   local parent = dir(dst)
   if parent ~= nil then
      mkdirp(parent)
   end
   efs.mkdir(dst)
end

local function delete(dst, recurse)
   check_efs_available("delete")
   if efs.file_type(dst) == nil then
      return
   end
   if efs.file_type(dst) == "file" then
      os.remove(dst)
   end
   if recurse then
      for o in efs.dir(dst) do
         local fullPath = combine(dst, o)
         if o ~= "." and o ~= ".." then
            if efs.file_type(fullPath) == "file" then
               os.remove(fullPath)
            elseif efs.file_type(fullPath) == "directory" then
               delete(fullPath, recurse)
            end
         end
      end
   end
   efs.rmdir(dst)
end

local function move(src, dst)
   return require "os".rename(src, dst)
end

local function exists(path)
   check_efs_available("exists")
   if efs.file_type(path) then
      return true
   else
      return false
   end
end

local function mkdir(...)
   check_efs_available("mkdir")
   efs.mkdir(...)
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

local fs = {
   write_file = write_file,
   read_file = read_file,
   copy_file = copy_file,
   mkdir = mkdir,
   mkdirp = mkdirp,
   delete = delete,
   exists = exists,
   move = move,
   EFS = efsLoaded,
   hash_file = hash_file
}

if efsLoaded then 
   return generate_safe_functions(merge_tables(fs, efs))
else 
   return generate_safe_functions(fs)
end
