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
   local _easy = curl.easy {
      url = url,
      writefunction = f
   }
   
   _easy:setopt_followlocation(followRedirects):setopt_ssl_verifypeer(verifyPeer):perform()
   local code = _easy:getinfo(curl.INFO_RESPONSE_CODE)
   _easy:close()
   f:close()
   return code
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
   local _easy = curl.easy {
      url = url,
      writefunction = append
   }

   _easy:setopt_followlocation(followRedirects):setopt_ssl_verifypeer(verifyPeer):perform()
   local code = _easy:getinfo(curl.INFO_RESPONSE_CODE)
   _easy:close()
   return code, result
end


return generate_safe_functions(
   {
      download_file = download_file,
      download_string = download_string
   }
)
