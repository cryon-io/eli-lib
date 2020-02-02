  
local _test = TEST or require 'u-test'
local _ok, _eliProc  = pcall(require, "eli.proc")

if not _ok then 
    _test["eli.proc available"] = function ()
        _test.assert(false, "eli.proc not available")
    end
    if not TEST then 
        _test.summary()
        os.exit()
    else 
        return 
    end
end

_test["eli.proc available"] = function ()
    _test.assert(true)
end

_test["execute"] = function ()
    local _ok, _exit, _code = _eliProc.execute("sh -c 'exit 173'")
    _test.assert(not _ok and _code == 173)
end

_test["execute_get_output"] = function ()
    local _ok, _exit, _code, _output = _eliProc.execute_get_output("sh -c \"printf 'test'\"")
    _test.assert(_ok and _output == 'test')
end

if not _eliProc.EPROC then
    if not TEST then 
        _test.summary()
        print"EPROC not detected, only basic tests executed..."
        os.exit()
    else 
        print"EPROC not detected, only basic tests executed..."
        return 
    end
end

_test["popen2"] = function ()
    local _proc, _rd, _wr = _eliProc.popen2("sh")
    _wr:write("printf '173'\n")
    _wr:write("exit\n")
    local _exit = _proc:wait()
    local _result = _rd:read("a")
    _test.assert(_exit == 0 and _result == "173")   
end

_test["popen3"] = function ()
    local _proc, _rd, _wr, _rderr = _eliProc.popen3("sh")
    _wr:write("printf '173'\n")
    _wr:write("printf 'error 173' >&2;\n")
    _wr:write("exit\n")
    local _exit = _proc:wait()
    local _result = _rd:read("a")
    local _error = _rderr:read("a")
    _test.assert(_exit == 0 and _result == "173" and _error == 'error 173')  
end

if not TEST then 
    _test.summary()
end