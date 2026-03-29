local M = {}

local defaults = {
  preview_max_chars = 3000,
  preview_debounce_ms = 0,
  preview_mode = 'full',
  show_hidden = false,
  keymap = {
    new_file = 'n',
    new_dir = 'N',
    edit = 'e',
    rename = 'r',
    select = '<space>',
    toggle_hidden = '.',
    yank = 'yy',
    cut = 'xx',
    delete = 'dd',
    paste = 'p',
  },
}

local function trim(s)
  if s == nil then return nil end
  return tostring(s):match '^%s*(.-)%s*$'
end

local function normalize(next_cfg)
  local out = lc.tbl_extend('force', {}, next_cfg or {})
  out.preview_max_chars = math.max(tonumber(out.preview_max_chars) or defaults.preview_max_chars, 1024)
  out.preview_debounce_ms = math.max(tonumber(out.preview_debounce_ms) or defaults.preview_debounce_ms, 0)
  out.preview_mode = tostring(out.preview_mode or defaults.preview_mode)
  if out.preview_mode ~= 'full' and out.preview_mode ~= 'file-only' then
    out.preview_mode = defaults.preview_mode
  end
  out.show_hidden = out.show_hidden == true
  out.keymap = out.keymap or {}
  out.keymap.new_file = trim(out.keymap.new_file) or defaults.keymap.new_file
  out.keymap.new_dir = trim(out.keymap.new_dir) or defaults.keymap.new_dir
  out.keymap.edit = trim(out.keymap.edit) or defaults.keymap.edit
  out.keymap.rename = trim(out.keymap.rename) or defaults.keymap.rename
  out.keymap.select = trim(out.keymap.select) or defaults.keymap.select
  out.keymap.toggle_hidden = trim(out.keymap.toggle_hidden) or defaults.keymap.toggle_hidden
  out.keymap.yank = trim(out.keymap.yank) or defaults.keymap.yank
  out.keymap.cut = trim(out.keymap.cut) or defaults.keymap.cut
  out.keymap.delete = trim(out.keymap.delete) or defaults.keymap.delete
  out.keymap.paste = trim(out.keymap.paste) or defaults.keymap.paste
  return out
end

function M.new(opt)
  local global_keymap = (lc.config.get() or {}).keymap or {}
  return normalize(lc.tbl_deep_extend('force', defaults, { keymap = global_keymap }, opt or {}))
end

return M
