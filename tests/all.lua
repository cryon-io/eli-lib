TEST = require 'u-test'
local _test = TEST
require"hash"
require"net"
require"fs"
require"proc"
require"env"
require"zip"

local _ntests, _nfailed = _test.result()
_test.summary()