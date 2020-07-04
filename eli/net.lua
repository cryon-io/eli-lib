local fetchLoaded, _fetch = pcall(require, "lfetch") -- "lcurl.safe"
local io = require "io"
local generate_safe_functions = require "eli.util".generate_safe_functions

local function download_file(url, destination, options)
   if not fetchLoaded then
      error("Networking not available!")
   end
   
   local flags = ""
   if type(options) == "table" then
      if options.verbose then 
         flags = flags .. "v"
      end
      if type(options.verifyPeer) == 'boolean' and not options.verifyPeer then 
         flags = flags .. "p"
      end
      if type(options.additionalFlags) == 'string' then 
         flags = flags .. additionalFlags
      end
   end
   
   local _didOpenFile, _df = pcall(io.open, destination, "w+b")
   if not _didOpenFile then
      error(_df)
   end

   local _fetchIO, _error = _fetch.get(url, flags)
   if type(_fetchIO) == "nil" then 
      error(_error)
   end

   while true do 
      local _chunk, _error = _fetchIO:read(1024)
      if type(_chunk) == "nil" then 
         error(_error)
      end
      if #_chunk == 0 then 
          break
      end
      _df:write(_chunk)
   end
   _df:close()
end

local function download_string(url, options) 
   if not fetchLoaded then
      error("Networking not available!")
   end

   local flags = ""
   if type(options) == "table" then
      if options.verbose then 
         flags = flags .. "v"
      end
      if type(options.verifyPeer) == 'boolean' and not options.verifyPeer then 
         flags = flags .. "p"
      end
      if type(options.additionalFlags) == 'string' then 
         flags = flags .. additionalFlags
      end
   end

   local result = ""

   _fetchIO, _error = _fetch.get(url, flags)
   if type(_fetchIO) == "nil" then 
      error(_error)
   end

   while true do 
      local _chunk, _error = _fetchIO:read(1024)
      if type(_chunk) == "nil" then 
         error(_error)
      end
      if #_chunk == 0 then 
          break
      end
      result = result .. _chunk
   end

   return result
end

return generate_safe_functions(
   {
      download_file = download_file,
      download_string = download_string
   }
)
