local function keys(t)
   local keys = {}
   for k, _ in pairs(t) do
      table.insert(keys, k)
   end
   return keys
end

local function values(t)
   local vals = {}
   for _, v in pairs(t) do
      table.insert(vals, v)
   end
   return vals
end

local function toArray(t)
   local arr = {}
   for k, v in pairs(t) do
      table.insert(arr, {key = k, value = v})
   end
   return arr
end

local function generate_safe_functions(functions)
   for k, v in pairs(functions) do
      if type(v) == "function" then
         functions["safe_" .. k] = function(...)
            pcall(v, ...)
         end
      end
   end
end

return {
   keys = keys,
   values = values,
   toArray = toArray,
   generate_safe_functions = generate_safe_functions
}
