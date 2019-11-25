local encode_to_json = require"hjson".encode_to_json
local is_tty = require"is_tty".is_stdout_tty()

local RESET_COLOR = string.char(27) .. "[0m"

local Logger = {}
Logger.__index = Logger

function Logger:new(options)
    local logger = {}
    if options == nil then 
        options = {}
    end
    if options.format == nil then
        options.format = 'auto'
    end
    if options.format == 'auto' then
        options.format = is_tty and 'standard' or 'json'
    end
    if options.colorful == nil then 
        options.colorful = is_tty
    end

    if options.level == nil then 
        options.level = 'info'
    end

    setmetatable(logger, self)
    self.__index = self
    logger.options = options
    return logger
end

local function get_log_color(level) 
    if level == 'success' then
        return string.char(27) .. "[32m"
    elseif level == 'debug' then
        return string.char(27) .. "[30;1m"
    elseif level == 'trace' then
        return string.char(27) .. "[30;1m"
    elseif level == 'info' then
        return string.char(27) .. "[36m"
    elseif level == 'warn' then
        return string.char(27) .. "[33m"
    elseif level == 'error' then
        return string.char(27) .. "[31m"
    else 
        return RESET_COLOR
    end
end

local function log_txt(data, colorful, color)
    local module = ''
    if data.module ~= nil and data.module ~= '' then 
       module = '('..tostring(module)..') ' 
    end
    if colorful then
        print(color .. os.date('%H:%M:%S') .. ' [' .. string.upper(data.level) .. '] ' .. module .. data.msg .. RESET_COLOR)
    else
        print(os.date('%H:%M:%S') .. ' [' .. string.upper(data.level) .. '] ' .. module .. data.msg)
    end
end

local function log_json(data)
    data.timestamp = os.time(os.date("!*t"))
    print(encode_to_json(data, false, true))
end

local function wrap_msg(msg)
    if type(msg) ~= table then
        return { msg = msg, level = 'info' }
    end
    return msg
end

function Logger:log(msg, lvl)
    msg = wrap_msg(msg)
    if lvl ~= nil then
        msg.level = lvl
    end
    if self.options.format == 'json' then
        log_json(msg)
    else 
        local color = get_log_color(msg.level)
        log_txt(msg, self.options.colorful, color)
    end
end

function Logger:success(msg)
    self:log(msg, 'success')
end

function Logger:debug(msg)
    self:log(msg, 'debug')
end

function Logger:trace(msg)
    self:log(msg, 'trace')
end

function Logger:info(msg)
    self:log(msg, 'info')
end

function Logger:warn(msg)
    self:log(msg, 'warn')
end

function Logger:error(msg)
    self:log(msg, 'error')
end

return Logger