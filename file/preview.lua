local M = {}

local config = require 'file.config'

local CODE_EXTENSIONS = {
  c = true,
  cc = true,
  cpp = true,
  css = true,
  go = true,
  h = true,
  hpp = true,
  html = true,
  java = true,
  js = true,
  json = true,
  jsx = true,
  lua = true,
  md = true,
  nix = true,
  py = true,
  rb = true,
  rs = true,
  sh = true,
  sql = true,
  toml = true,
  ts = true,
  tsx = true,
  txt = true,
  xml = true,
  yaml = true,
  yml = true,
  zig = true,
}

local SPECIAL_FILENAMES = {
  ['Dockerfile'] = 'dockerfile',
  ['Makefile'] = 'makefile',
  ['justfile'] = 'makefile',
}

local function span(text, color)
  local s = lc.style.span(tostring(text or ''))
  if color and color ~= '' then s = s:fg(color) end
  return s
end

local function line(parts) return lc.style.line(parts) end
local function text(lines) return lc.style.text(lines) end

local function sort_entries(entries)
  table.sort(entries, function(a, b)
    if a.is_dir ~= b.is_dir then return a.is_dir end
    return string.lower(a.name) < string.lower(b.name)
  end)
  return entries
end

local function read_children(path)
  local entries, err = lc.fs.read_dir_sync(path)
  if err then return nil, err end
  return sort_entries(entries or {})
end

local function language_for(name)
  if SPECIAL_FILENAMES[name] then return SPECIAL_FILENAMES[name] end
  local ext = tostring(name):match '%.([^.]+)$'
  if not ext then return nil end
  ext = string.lower(ext)
  if CODE_EXTENSIONS[ext] then return ext end
  return nil
end

local function directory_lines(path)
  local entries, err = read_children(path)
  if err then
    return {
      line { span('Failed to read directory', 'red') },
      line { span(err, 'red') },
    }
  end

  if #entries == 0 then
    return {
      line { span('Empty directory', 'darkgray') },
    }
  end

  local lines = {
    line { span(path, 'cyan') },
    line { span(string.format('%d items', #entries), 'darkgray') },
    line { '' },
  }

  for _, entry in ipairs(entries) do
    table.insert(lines, line {
      span(entry.name, entry.is_dir and 'blue' or 'white'),
    })
  end

  return lines
end

local function truncate_content(content)
  local max_chars = config.get().preview_max_chars
  if #content <= max_chars then return content, false end
  return content:sub(1, max_chars), true
end

local function read_file_preview(path)
  local content, err = lc.fs.read_file_sync(path)
  if err then
    return text {
      line { span('Failed to read file', 'red') },
      line { span(err, 'red') },
    }
  end

  if content:find('\0', 1, true) then
    return text {
      line { span('Binary file', 'yellow') },
      line { span(path, 'white') },
    }
  end

  local truncated
  content, truncated = truncate_content(content)
  local language = language_for(path:match '[^/]+$' or path)

  if truncated then
    if language then return lc.style.highlight(content, language) end
    return text {
      line { span('Preview truncated', 'yellow') },
      line { span(path, 'cyan') },
      line { '' },
      content,
    }
  end

  if language then return lc.style.highlight(content, language) end
  return text { content }
end

function M.dir_preview(entry)
  return text(directory_lines(entry.path))
end

function M.file_preview(entry)
  return read_file_preview(entry.path)
end

function M.info_preview(entry)
  return text {
    line { span(entry.message or 'file', entry.color or 'darkgray') },
  }
end

return M
