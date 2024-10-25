local wezterm = require 'wezterm'

wezterm.on('update-right-status', function(window, pane)
    -- Each element holds the text for a cell in a "powerline" style << fade
    local cells = {}

    -- Figure out the cwd and host of the current pane.
    -- This will pick up the hostname for the remote host if your
    -- shell is using OSC 7 on the remote host.
    local cwd_uri = pane:get_current_working_dir()
    if cwd_uri then
        local cwd = cwd_uri.file_path:gsub("^/", ""):gsub("/$", "")
        local hostname = wezterm.hostname()

        table.insert(cells, cwd)
        table.insert(cells, hostname)
    end

    -- I like my date/time in this style: "Wed 3 Mar 08:14"
    local date = wezterm.strftime '%a %-d %b %H:%M'
    table.insert(cells, date)

    -- An entry for each battery (typically 0 or 1 battery)
    for _, b in ipairs(wezterm.battery_info()) do
        table.insert(cells, string.format('Battery: %.0f%%', b.state_of_charge * 100))
    end

    -- The powerline < symbol
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

    -- Color palette for the backgrounds of each cell
    local colors = {
        '#3c1361',
        '#52307c',
        '#663a82',
        '#7c5295',
        '#b491c8',
    }

    -- Foreground color for the text across the fade
    local text_fg = '#c0c0c0'

    -- The elements to be formatted
    local elements = {}
    -- How many cells have been formatted
    local num_cells = 0

    -- The first left arrow on the right elements of the powerline
    table.insert(elements, { Foreground = { Color = colors[1] } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })

    -- Translate a cell into elements
    local function push(text, is_last)
        local cell_no = num_cells + 1
        table.insert(elements, { Foreground = { Color = text_fg } })
        table.insert(elements, { Background = { Color = colors[cell_no] } })
        table.insert(elements, { Text = ' ' .. text .. ' ' })
        if not is_last then
            table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
            table.insert(elements, { Text = SOLID_LEFT_ARROW })
        end
        num_cells = num_cells + 1
    end

    while #cells > 0 do
        local cell = table.remove(cells, 1)
        push(cell, #cells == 0)
    end

    window:set_right_status(wezterm.format(elements))
end)
