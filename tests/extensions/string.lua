local _test = TEST or require "u-test"
local _ok, _exString = pcall(require, "eli.extensions.string")

if not _ok then
    _test["eli.extensions.string available"] = function()
        _test.assert(false, "eli.extensions.string not available")
    end
    if not TEST then
        _test.summary()
        os.exit()
    else
        return
    end
end

_test["eli.extensions.string available"] = function()
    _test.assert(true)
end

_test["trim"] = function()
    local _result = _exString.trim("   \ttest \t\n ")
    _test.assert(_result == "test")
end

_test["join"] = function()
    local _result = _exString.join(", ", "test", "join", "string")
    _test.assert(_result == "test, join, string")
    local _ok, _result = pcall(_exString.join, ", ", "test", {"join"}, "string")
    _test.assert(not _ok)
end

_test["join_strings"] = function()
    local _result = _exString.join_strings(", ", "test", "join", {test = "string"}, "string")
    _test.assert(_result == "test, join, string")
    local _ok, _result = pcall(_exString.join_strings, ", ", "test", {"join"}, "string")
    _test.assert(_ok)
end

_test["split"] = function()
    local _result = _exString.split("test, join, string", ",", true)
    _test.assert(_result[1] == "test" and _result[2] == "join" and _result[3] == "string")
end

_test["globalize"] = function()
    _exString.globalize()
    for k, v in pairs(_exString) do
        if k ~= "globalize" then
            _test.assert(string[k] == v)
        end
    end
end

if not TEST then
    _test.summary()
end
