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

local function is_array(t)
   if type(t) ~= "table" then
      return false
   end
   local i = 0
   for k in pairs(t) do
      i = i + 1
      if i ~= k then
         return false
      end
   end
   return true
end

local function merge_tables(t1, t2, overwrite) 
   for k,v2 in pairs(t2) do
       local v1 = t1[k]         
       if type(v1) == 'table' and type(v2) == 'table' then
           v1 = merge_tables(v1, v2)
       elseif type(v1) == 'nil' then
           t1[k] = v2
       elseif overwrite then
           t1[k] = v2 
       end
   end
   return t1
end

function escape_magic_characters(s)
   return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1"))
end


local function filter_table(t, _filter)
   if type(_filter) ~= "function" then
       return t
   end
   local isArray = is_array(t)

   local res = {}
   for k, v in pairs(t) do
       if _filter(k, v) then
           if isArray then
               table.insert(res, v)
           else
               res[k] = v
           end
       end
   end
   return res
end

local function generate_safe_functions(functions)
   if type(functions) ~= 'table' then 
      return functions
   end
   local res = {}

   for k, v in pairs(functions) do
      if type(v) == "function" and not k:match("^safe_") then
         res["safe_" .. k] = function(...)
            return pcall(v, ...)
         end
      end
   end
   return merge_tables(functions, res)
end

local function print_table(t) 
   if type(t) ~= 'table' then 
      return 
   end
   for k, v in pairs(t) do 
      print(k, v)
   end
end

local function _global_log_factory(module, ...)
   local _result = {}
   for i,v in ipairs({...}) do
      if type(GLOBAL_LOGGER) ~= 'table' and GLOBAL_LOGGER.__type ~= 'ELI_LOGGER' then
         table.insert(_result, function() end)
      else
         table.insert(_result, function(msg)
            if type(msg) ~= 'table' then
                msg = { msg = msg }
            end
            msg.module = module
            return GLOBAL_LOGGER:log(msg, v)
         end)
      end
   end
   return table.unpack(_result)
end

return {
   keys = keys,
   values = values,
   toArray = toArray,
   generate_safe_functions = generate_safe_functions,
   is_array = is_array,
   escape_magic_characters = escape_magic_characters,
   filter_table = filter_table,
   merge_tables = merge_tables,
   print_table = print_table,
   global_log_factory = _global_log_factory
}
