string.split = function (s, pattern)
    local result = {}
    for word in s:gmatch(pattern) do table.insert(result, word) end
    return result 
end