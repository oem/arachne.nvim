M = {}

M.options = {}

local defaults = {
    notes_directory = os.getenv("HOME") .. "/notes",
    file_extension = '.md',
}

local known_headings = {
    md = { '---', 'title: <TITLE>', '---' },
    org = {
        '#+title:      <TITLE>',
        '#+date:       <DATE>',
        '#+filetags:   <TAGS>'
    },
    norg = {
        '@document.meta',
        'title: <TITLE>',
        'created: <DATE>',
        '@end'
    },
}

local tags_to_text = function(tags, sep) return table.concat(tags, sep) end

local text_to_tags = function(raw_tags)
    local tags = {}
    for i in string.gmatch(raw_tags, "([^%s*,%s*]+)") do
        table.insert(tags, i)
    end
    return tags
end

M.new = function(file_extension)
    local title = ""
    local raw_tags = ""
    local tags = {}
    file_extension = file_extension or M.options.file_extension
    vim.ui.input({ prompt = "Enter title: " }, function(input) title = input end)
    if title == nil then
        print("The title is required.")
        return
    end
    title = title.gsub(title, "%s+$", "")

    vim.ui.input({ prompt = "Enter tags (comma separated): " },
        function(input) raw_tags = input end)

    if raw_tags ~= nil then tags = text_to_tags(raw_tags) end

    M._open(title, tags, file_extension)
end

M.rename = function()
    local current = vim.api.nvim_buf_get_name(0)
    local date, title, tags, extension = M._deconstruct_slug(current)

    vim.ui.input({
        prompt = "Enter date <YYYY-MM-DD> (press enter to use " .. date .. "): "
    }, function(input) date = input or date end)

    vim.ui.input({
        prompt = "Enter title (press enter to reuse " .. title .. "): "
    }, function(input) title = input or title end)

    vim.ui.input({
        prompt = "Enter tags (comma separated, press enter to reuse " ..
            tags_to_text(tags, ',') .. "): "
    }, function(input) if input ~= nil then tags = text_to_tags(input) end end)

    vim.ui.input({
        prompt = string.format("Enter extension (press enter to reuse %s): ", extension)
    }, function(input) extension = input or extension end)

    local new_name = M._build_slug(date, title, tags, extension)
    new_name = M.options.notes_directory .. "/" .. new_name
    os.rename(current, new_name)
    vim.api.nvim_buf_set_name(0, new_name)
    vim.cmd("e")
end

M._open = function(title, tags, extension)
    local date_prefix = os.date("%Y-%m-%d")
    local file_name = M._build_slug(date_prefix, title, tags, extension)
    vim.cmd("e " .. M.options.notes_directory .. "/" .. file_name)

    for ext, template in pairs(known_headings) do
        if vim.endswith(file_name, '.' .. ext) then
            for i, _ in ipairs(template) do
                template[i] = template[i]:gsub("<TITLE>", title)
                template[i] = template[i]:gsub("<DATE>", date_prefix)
                template[i] = template[i]:gsub("<TAGS>", ':' .. table.concat(tags, ':') .. ':')
            end
            vim.api.nvim_put(template, "l", false, true)
            break
        end
    end
end

M._build_slug = function(date, title, tags, extension)
    local normalized_name = string.lower(title)
    normalized_name = string.gsub(normalized_name, "%s+", "-")

    local file_tags = table.concat(tags, "_")
    local postfix = ""
    if file_tags ~= "" then postfix = "__" .. file_tags end

    local file_name = date .. "--" .. normalized_name .. postfix .. extension
    return file_name
end

M._deconstruct_slug = function(filename)
    local date, title, raw_tags, extension = filename:match(
        "(%d+-%d+-%d%d)--([^-].+)__(.+)(%..+)$")
    title = title or ""
    local tags = {}
    if date == nil then date = os.date("%Y-%m-%d") end

    if raw_tags ~= nil then
        for i in raw_tags:gmatch("[^_]+") do table.insert(tags, i) end
    end

    return date, title, tags, extension
end

M.setup = function(opts)
    M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M
