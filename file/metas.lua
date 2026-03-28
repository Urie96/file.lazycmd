local M = {}

local config = require 'file.config'
local preview = require 'file.preview'

local function preview_method(renderer)
  return function(self, cb) cb(renderer(self)) end
end

local function add_keymap(map, key, callback, desc)
  if key and key ~= '' then map[key] = { callback = callback, desc = desc } end
end

local function open_directory(self) lc.api.go_to(self.path_parts or {}) end

local function refresh_preview(self)
  local renderer = self.is_dir and preview.dir_preview or preview.file_preview
  lc.api.page_set_preview(renderer(self))
end

local function entry_keymap(self)
  local map = {}
  local keymap = config.get().keymap

  if self.is_dir then
    add_keymap(map, keymap.open, function() open_directory(self) end, 'enter directory')
    add_keymap(map, keymap.enter, function() open_directory(self) end, 'enter directory')
  else
    add_keymap(map, keymap.open, function() refresh_preview(self) end, 'refresh preview')
    add_keymap(map, keymap.enter, function() refresh_preview(self) end, 'refresh preview')
  end

  return map
end

local function info_keymap()
  local map = {}
  local keymap = config.get().keymap
  add_keymap(map, keymap.open, function() end, 'no action')
  add_keymap(map, keymap.enter, function() end, 'no action')
  return map
end

local dir_mt = {
  __index = function(self, key)
    if key == 'preview' then return preview_method(preview.dir_preview) end
    if key == 'keymap' then return entry_keymap(self) end
  end,
}

local file_mt = {
  __index = function(self, key)
    if key == 'preview' then return preview_method(preview.file_preview) end
    if key == 'keymap' then return entry_keymap(self) end
  end,
}

local info_mt = {
  __index = function(self, key)
    if key == 'preview' then return preview_method(preview.info_preview) end
    if key == 'keymap' then return info_keymap() end
  end,
}

local metatables = {
  dir = dir_mt,
  file = file_mt,
  info = info_mt,
}

function M.attach_all(entries)
  local out = {}
  for _, entry in ipairs(entries or {}) do
    local mt = metatables[entry.kind]
    if mt then
      table.insert(out, setmetatable(entry, mt))
    else
      table.insert(out, entry)
    end
  end
  return out
end

return M
