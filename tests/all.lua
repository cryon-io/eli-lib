TEST = require 'u-test'
local _test = TEST
require"hash"
require"net"
require"fs"

-- obtain total number of tests and numer of failed tests
local _ntests, _nfailed = _test.result()

-- this code prints tests summary and invokes os.exit with 0 or 1
_test.summary()