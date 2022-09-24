M = {}

M.options = {}

local defaults = {notes_directory = os.getenv("HOME") .. "/notes"}

M.new = function(name, tags)
    local date_prefix = os.date("%Y-%m-%d")
    local file_tags = table.concat(tags, "_")
    local postfix = ""
    if file_tags ~= "" then postfix = "__" .. file_tags end

    local file_name = date_prefix .. "--" .. name .. postfix .. ".md"
    vim.cmd("e " .. M.options.notes_directory .. "/" .. file_name)
end

M.rename = function() end

M.setup = function(opts)
    M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M
