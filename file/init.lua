local Browser = require 'file.browser'
local LocalProvider = require 'file.provider.local'

local M = {}

local default_browser = nil

local function ensure_default_browser()
  if not default_browser then
    default_browser = M.new_local({})
  end
  return default_browser
end

function M.new(provider, opt)
  return Browser.new(provider, opt or {})
end

function M.new_local(opt)
  return Browser.new(LocalProvider.new(opt or {}), opt or {})
end

function M.setup(opt)
  default_browser = M.new_local(opt or {})
end

function M.list(path, cb)
  return ensure_default_browser():list(path, cb)
end

function M.preview(entry, cb)
  return ensure_default_browser():preview(entry, cb)
end

function M.copy_hovered_entry()
  return ensure_default_browser().actions:copy_hovered_entry()
end

return M
