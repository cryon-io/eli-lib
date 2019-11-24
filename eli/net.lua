local curlLoaded, curl = pcall(require, "cURL") -- "lcurl.safe"
local io = require "io"
local generate_safe_functions = require "eli.util".generate_safe_functions

local function download_file(url, destination, options)
   if not curlLoaded then
      error("Networking not available...")
   end

   if type(options) == "table" then
      followRedirects = options.follow_redirects
      verifyPeer = options.verify_peer
   end
   if verifyPeer == nil then
      verifyPeer = true
   end
   if followRedirects == nil then
      followRedirects = false
   end

   if followRedirects == nil then
      followRedirects = true
   end
   if verifyPeer == nil then
      verifyPeer = true
   end
   local f = io.open(destination, "w+b")
   curl.easy {
      url = url,
      writefunction = f
   }:setopt_followlocation(followRedirects):setopt_ssl_verifypeer(verifyPeer):perform():close()
   f:close()
end

return generate_safe_functions(
   {
      download_file = download_file
   }
)
