M = {}

-- User can set a notes directory that we can use here
-- The fileformat should probably also be configurable, but we will start with markdown as default
M.new = function(name, tags)
    local date_prefix = os.date("%Y-%m-%d")
    local file_tags = table.concat(tags, "_")
    local file_name = date_prefix .. "--" .. name .. "__" .. file_tags .. ".md"
    vim.cmd("e " .. file_name)
end

M.rename = function() end

M.setup = function() end

return M
