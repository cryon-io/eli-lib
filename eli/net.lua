local curl = require"cURL" -- "lcurl.safe"
local io = require"io"

local function downloadfile(url, destination, options)
   if type(options) == 'table' then
      followRedirects = options.follow_redirects
      verifyPeer = options.verify_peer
   end
   if verifyPeer == nil then verifyPeer = true end
   if followRedirects == nil then followRedirects = false end   

   if followRedirects == nil then
      followRedirects = true
   end 
   if verifyPeer == nil then
      verifyPeer = true
   end
   local f = io.open(destination, "w+b") 
   curl.easy{
      url = url,
      writefunction = f
   }
   :setopt_followlocation(followRedirects)
   :setopt_ssl_verifypeer(verifyPeer)
   :perform():close()
   f:close()
end

return {
   downloadfile = downloadfile
}
