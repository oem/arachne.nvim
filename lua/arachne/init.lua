M = {}

M.options = {}

local defaults = {notes_directory = os.getenv("HOME") .. "/notes"}

local tags_to_text = function(tags, sep) return table.concat(tags, sep) end

local text_to_tags = function(raw_tags)
    local tags = {}
    for i in string.gmatch(raw_tags, "([^%s*,%s*]+)") do
        table.insert(tags, i)
    end
    return tags
end

M.new = function()
    local title = ""
    local raw_tags = ""
    local tags = {}

    vim.ui.input({prompt = "Enter title: "}, function(input) title = input end)
    if title == nil then
        print("The title is required.")
        return
    end
    title = title.gsub(title, "%s+$", "")

    vim.ui.input({prompt = "Enter tags (comma separated): "},
                 function(input) raw_tags = input end)

    if raw_tags ~= nil then tags = text_to_tags(raw_tags) end

    M._open(title, tags)
end

M._open = function(name, tags)
M._open = function(title, tags)
    local date_prefix = os.date("%Y-%m-%d")
    local file_name = M._build_slug(date_prefix, title, tags)
    vim.cmd("e " .. M.options.notes_directory .. "/" .. file_name)
    vim.api.nvim_put({"# " .. title}, "l", false, true)
end

M._build_slug = function(date, title, tags)
    local normalized_name = string.lower(title)
    normalized_name = string.gsub(normalized_name, "%s+", "-")

    local file_tags = table.concat(tags, "_")
    local postfix = ""
    if file_tags ~= "" then postfix = "__" .. file_tags end

    local file_name = date .. "--" .. normalized_name .. postfix .. ".md"
    return file_name
end

M._deconstruct_slug = function(filename)
    local date, title, raw_tags = filename:match(
                                      "(%d+-%d+-%d%d)--([^-].+)__(.+).md")
    local tags = nil
    if date == nil then date = os.date("%Y-%m-%d") end

    if raw_tags ~= nil then
        tags = {}
        for i in raw_tags:gmatch("[^_]+") do table.insert(tags, i) end
    end

    return date, title, tags
end

M.setup = function(opts)
    M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M
