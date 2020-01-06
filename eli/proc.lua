local io = require"io"
local util = require"eli.util"
local generate_safe_functions = util.generate_safe_functions
local merge_tables = util.merge_tables
local eprocLoaded, eproc = pcall(require, "eli.proc.extra")
local fs = require"eli.fs"

local function execute_get_output(cmd) 
   f = io.popen(cmd)
   output = f:read"a*"
   success, exit, code = f:close()
   return success, exit, code, output
end

local proc = {
   execute_get_output = execute_get_output,
   popen = io.popen
}

if not eprocLoaded or type(fs.pipe) ~= 'function' then 
   return generate_safe_functions(proc)
end

local function popen2(...)
   local proc_rd, wr = fs.pipe()
   local rd, proc_wr = fs.pipe()
   local proc, err = eproc.spawn{stdin = proc_rd, stdout = proc_wr, ...}
   proc_rd:close(); proc_wr:close()
   if not proc then
      wr:close(); rd:close()
      return proc, err
   end
   return proc, rd, wr
end

local function popen3(...)
   local proc_rd, wr = fs.pipe()
   local rd, proc_wr = fs.pipe()
   local rderr, proc_werr = fs.pipe()

   local proc, err = eproc.spawn{stdin = proc_rd, stdout = proc_wr, stderr = proc_werr, ...}
   proc_rd:close(); proc_wr:close(); proc_werr:close()
   if not proc then
      wr:close(); rd:close(); rderr:close()
      return proc, err
   end
   return proc, rd, wr, rderr
end

proc.popen2 = popen2
proc.popen3 = popen3

return generate_safe_functions(merge_tables(proc, eproc))
