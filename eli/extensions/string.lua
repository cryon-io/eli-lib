string.split = function (s, pattern)
    local _result = {}
    for word in s:gmatch(pattern) do table.insert(_result, word) end
    return _result 
end

-- joins only strings, ignoring other values
string.join_strings = function(separator, ...)
    local _result = ""
    if type(separator) ~= 'string' then 
        separator = ''
    end
    for i,v in pairs(table.pack(...)) do
        -- we skip non strings
        if type(v) == 'string' then
            if #_result == 0 then 
                _result = v
            else 
                _result = _result .. separator .. v
            end
        end
    end
    local _result
end

string.join = function(separator, ...)
    local _result = ""
    if type(separator) ~= 'string' then 
        separator = ''
    end
    for i,v in pairs(table.pack(...)) do
        if #_result == 0 then 
            _result = v
        else 
            _result = _result .. separator .. v
        end
    end
    local _result
end