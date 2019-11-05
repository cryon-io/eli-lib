local io = require"io"
local lfs = require"lfs"
local dir = require"eli.path".dir
local combine = require"eli.path".combine

local function readfile(src)
   local f = assert(io.open(src, "r"), "No such a file or directory - " .. src)
   local result = f:read("a*")
   f:close()
   return result
end

local function writefile(dst, content)
   local f = assert(io.open(dst, "w"), "No such a file or directory - " .. dst)
   f:write(content)
   f:close()
end

local function copyfile(src, dst)
   assert(src ~= dst)
   local srcf = assert(io.open(src, "r"), "No such a file or directory - " .. src)
   local dstf = assert(io.open(dst, "w"), "Failed to open file for write - " .. dst)

   local size = 2^13 -- 8K
   while true do
      local block = srcf:read(size)
      if not block then break end
      dstf:write(block)
   end
end

local function mkdirp(dst)
   local parent = dir(dst)
   if parent ~= nil then
      mkdirp(parent)
   end
   lfs.mkdir(dst)
end

local function delete(dst, recurse)
    if lfs.attributes(dst) == nil then
       return
    end
    if lfs.attributes(dst, "mode") == 'file' then
       os.remove(dst)
    end
    if recurse then
       for o in lfs.dir(dst) do
          local fullPath = combine(dst, o)
          if o ~= "." and o ~= ".." then
             if lfs.attributes(fullPath, 'mode') == 'file' then
                os.remove(fullPath)
             elseif lfs.attributes(fullPath, 'mode') == 'directory' then
                delete(fullPath, recurse)
             end
         end
       end
    end
    lfs.rmdir(dst)
end

local function move(src, dst)
   return require"os".rename(src, dst)
end

return {
    writefile = writefile,
    readfile = readfile,
    copyfile = copyfile,
    mkdir = lfs.mkdir,
    mkdirp = mkdirp,
    delete = delete
}
