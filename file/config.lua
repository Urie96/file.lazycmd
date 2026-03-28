local M = {}

local cfg = {
  preview_max_chars = 60000,
  keymap = {
    open = '<right>',
    enter = '<enter>',
  },
}

local function trim(s)
  if s == nil then return nil end
  return tostring(s):match '^%s*(.-)%s*$'
end

local function normalize(next_cfg)
  local out = lc.tbl_extend('force', {}, next_cfg or {})
  out.preview_max_chars = math.max(tonumber(out.preview_max_chars) or cfg.preview_max_chars, 1024)
  out.keymap = out.keymap or {}
  out.keymap.open = trim(out.keymap.open) or cfg.keymap.open
  out.keymap.enter = trim(out.keymap.enter) or cfg.keymap.enter
  return out
end

function M.setup(opt)
  local global_keymap = (lc.config.get() or {}).keymap or {}
  cfg = normalize(lc.tbl_deep_extend('force', cfg, {
    keymap = {
      open = global_keymap.open,
      enter = global_keymap.enter,
    },
  }, opt or {}))
end

function M.get() return cfg end

return M
