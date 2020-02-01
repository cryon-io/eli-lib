local curlLoaded, curl = pcall(require, "cURL") -- "lcurl.safe"
local io = require "io"
local generate_safe_functions = require "eli.util".generate_safe_functions

assert(curlLoaded, "eli.net requires cURL")

local function download_file(url, destination, options)
   if not curlLoaded then
      error("Networking not available!")
   end

   local followRedirects = false
   local verifyPeer = true
   if type(options) == "table" then
      followRedirects = options.followRedirects or followRedirects
      verifyPeer = options.verify_peer or verifyPeer
   end
   
   local f = io.open(destination, "w+b")
   curl.easy {
      url = url,
      writefunction = f
   }:setopt_followlocation(followRedirects):setopt_ssl_verifypeer(verifyPeer):perform():close()
   f:close()
end

local function download_string(url, options) 
   if not curlLoaded then
      error("Networking not available!")
   end

   local followRedirects = false
   local verifyPeer = true
   if type(options) == "table" then
      followRedirects = options.followRedirects or followRedirects
      verifyPeer = options.verify_peer
      if verifyPeer == nil then 
         verifyPeer = true
      end
   end
   
   local result = ""
   local function append(data) 
      result = result .. data
   end
   curl.easy {
      url = url,
      writefunction = append
   }:setopt_followlocation(followRedirects):setopt_ssl_verifypeer(verifyPeer):perform():close()
   return result
end


return generate_safe_functions(
   {
      download_file = download_file,
      download_string = download_string
   }
)
