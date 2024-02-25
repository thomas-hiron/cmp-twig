local source = {}

local handle = io.popen('rg --no-filename --no-line-number --no-heading "new Twig(Filter|Function)" src')
local result = handle:read("*a")
handle:close()

local filters = require('cmp_twig.filters')
local functions = require('cmp_twig.functions')

for line in result:gmatch("[^\r\n]+") do
  local is_filter = line:match("TwigFilter") ~= nil
  local match = line:match("new Twig[A-Za-z]+%('([A-Za-z0-9_]+)'")
end

function source.new()
  local self = setmetatable({}, { __index = source })
  return self
end

function source.get_debug_name()
  return 'twig'
end

function source.is_available()
  local filetypes = { 'twig' }

  return vim.tbl_contains(filetypes, vim.bo.filetype)
end

function source.get_trigger_characters()
  return { '|', ' ', '(' }
end

function source.complete(self, request, callback)
  local input = string.sub(request.context.cursor_before_line, request.offset - 1)

  local completion_array
  local documentation
  if vim.startswith(input, '|') then
    completion_array = filters
    documentation = "Filter"
  else
    completion_array = functions
    documentation = "Function"
  end

  local items = {}
  for k, filter in pairs(completion_array) do
    table.insert(items, {
      label = filter,
      documentation = {
        kind = 'markdown',
        value = '_Twig type_: ' .. documentation
      },
    })
  end

  callback {
    items = items,
    isIncomplete = true,
  }
end

return source
