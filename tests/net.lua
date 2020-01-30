local _test = TEST or require 'u-test'
local _ok, _eliNet = pcall(require, "eli.net")
local _sha256sum = require "lmbed_hash".sha256sum

if not _ok then 
    _test["eli.net available"] = function ()
        _test.assert(false, "eli.net not available")
    end
    if not TEST then 
        local _ntests, _nfailed = _test.result()
        _test.summary()
        os.exit()
    else 
        return 
    end
end

_test["eli.net available"] = function ()
    _test.assert(true)
end

_test["download_string"] = function ()
    local _expected = "a5bcc6d25b3393fc7a4e356af681561ab9fd558a2b220654b6e387b39e733388"
    local _ok, _s = _eliNet.safe_download_string("https://raw.githubusercontent.com/cryon-io/eli/master/LICENSE")
    _test.assert(_ok, _s)
    local _result = _sha256sum(_s, true)
    _test.assert(_expected == _result, "hashes do not match")
end

_test["download_file"] = function ()
    local _expected = "a5bcc6d25b3393fc7a4e356af681561ab9fd558a2b220654b6e387b39e733388"
    local _ok = _eliNet.safe_download_file("https://raw.githubusercontent.com/cryon-io/eli/master/LICENSE", "tmp/LICENSE")
    _test.assert(_ok, _file)
    local _ok, _file = pcall(io.open, "tmp/LICENSE", "r")
    _test.assert(_ok, _file)
    local _ok, _s = pcall(_file.read, _file, "a")
    _test.assert(_ok, _s)
    local _result = _sha256sum(_s, true)
    _test.assert(_expected == _result, "hashes do not match")
end

if not TEST then 
    -- obtain total number of tests and numer of failed tests
    local _ntests, _nfailed = _test.result()

    -- this code prints tests summary and invokes os.exit with 0 or 1
    _test.summary()
end