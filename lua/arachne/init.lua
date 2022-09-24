M = {}

M.options = {}

local defaults = {notes_directory = os.getenv("HOME") .. "/notes"}

M.new = function()
    local title = ""
    local raw_tags = ""
    local tags = {}

    vim.ui.input({prompt = "Enter title: "}, function(input) title = input end)
    vim.ui.input({prompt = "Enter tags (comma separated): "},
                 function(input) raw_tags = input end)
    for i in string.gmatch(raw_tags, "([^%s*,%s*]+)") do
        table.insert(tags, i)
    end

    M.open(title, tags)
end

M.open = function(name, tags)
    local date_prefix = os.date("%Y-%m-%d")

    local normalized_name = string.lower(name)
    normalized_name = string.gsub(normalized_name, " +", "-")

    local file_tags = table.concat(tags, "_")
    local postfix = ""
    if file_tags ~= "" then postfix = "__" .. file_tags end

    local file_name = date_prefix .. "--" .. normalized_name .. postfix .. ".md"
    vim.cmd("e " .. M.options.notes_directory .. "/" .. file_name)
    vim.api.nvim_put({"# " .. name}, "l", false, true)
end

M.rename = function() end

M.setup = function(opts)
    M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M
