-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

-- This will hold the configuration.
local config = wezterm.config_builder()

-- https://wezfurlong.org/wezterm/config/lua/gui-events/gui-startup.html
wezterm.on('gui-startup', function(cmd)
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

wezterm.on('update-right-status', function(window, pane)
    window:set_right_status(window:active_workspace())
end)

local launch_menu = {}
if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    local default_prog = { 'cmd.exe ', '/k',
        'C:/msys64/msys2_shell.cmd -defterm -here -no-start -mingw64 -use-full-path -shell zsh' }

    table.insert(launch_menu, {
        label = 'MSYS MINGW64',
        args = default_prog,
    })
    table.insert(launch_menu, {
        label = 'PowerShell',
        args = { 'pwsh.exe', '-nol' },
    })

    config.default_prog = default_prog
else
    config.default_prog = { '/usr/bin/zsh' }
end

config.launch_menu = launch_menu


-- This is used to make my foreground (text, etc) brighter than my background
config.foreground_text_hsb = {
    hue = 0.8,
    saturation = 0.9,
    brightness = 1.5,
}

-- Color scheme, Wezterm has 100s of them you can see here:
-- https://wezfurlong.org/wezterm/colorschemes/index.html
-- config.color_scheme = 'Oceanic Next (Gogh)'
config.color_schemes = {
    ['Oceanic Next (Gogh)'] = {
    -- ['thwump (terminal.sexy) '] = {
        background = 'black',
        -- TODO cursor opts non working
        cursor_bg = 'white',
        cursor_border = '#8b8198',
        cursor_fg = '#8b8198',
    },
}
config.color_scheme = 'thwump (terminal.sexy) '
-- config.color_scheme = '3024 Night (Gogh)'
config.window_frame = {
    -- The font used in the tab bar.
    -- Roboto Bold is the default; this font is bundled
    -- with wezterm.
    -- Whatever font is selected here, it will have the
    -- main font setting appended to it to pick up any
    -- fallback fonts you may have used there.
    font = wezterm.font { family = 'Roboto', weight = 'Bold' },

    -- The size of the font in the tab bar.
    -- Default to 10.0 on Windows but 12.0 on other systems
    font_size = 10.0,

    -- The overall background color of the tab bar when
    -- the window is focused
    active_titlebar_bg = '#333333',

    -- The overall background color of the tab bar when
    -- the window is not focused
    inactive_titlebar_bg = '#333333',
}

config.colors = {
    tab_bar = {
        -- The color of the inactive tab bar edge/divider
        inactive_tab_edge = '#575757',
    },
}

-- config.window_background_gradient = {
--     -- Can be "Vertical" or "Horizontal".  Specifies the direction
--     -- in which the color gradient varies.  The default is "Horizontal",
--     -- with the gradient going from left-to-right.
--     -- Linear and Radial gradients are also supported; see the other
--     -- examples below
--     orientation = 'Vertical',
--
--     -- Specifies the set of colors that are interpolated in the gradient.
--     -- Accepts CSS style color specs, from named colors, through rgb
--     -- strings and more
--     --[[ colors = {
--         '#0f0c29',
--         '#302b63',
--         '#24243e',
--     }, -- Cold
--     colors = { '#EEBD89', '#D13ABD' }, -- Calid ]]
--
--     -- Instead of specifying `colors`, you can use one of a number of
--     -- predefined, preset gradients.
--     -- A list of presets is shown in a section below.
--     -- https://wezfurlong.org/wezterm/config/lua/config/window_background_gradient.html?h=preset#presets
--     preset = "Viridis",
--
--     -- Specifies the interpolation style to be used.
--     -- "Linear", "Basis" and "CatmullRom" as supported.
--     -- The default is "Linear".
--     interpolation = 'Linear',
--
--     -- How the colors are blended in the gradient.
--     -- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
--     -- The default is "Rgb".
--     blend = 'Rgb',
--
--     -- To avoid vertical color banding for horizontal gradients, the
--     -- gradient position is randomly shifted by up to the `noise` value
--     -- for each pixel.
--     -- Smaller values, or 0, will make bands more prominent.
--     -- The default value is 64 which gives decent looking results
--     -- on a retina macbook pro display.
--     -- noise = 64,
--
--     -- By default, the gradient smoothly transitions between the colors.
--     -- You can adjust the sharpness by specifying the segment_size and
--     -- segment_smoothness parameters.
--     -- segment_size configures how many segments are present.
--     -- segment_smoothness is how hard the edge is; 0.0 is a hard edge,
--     -- 1.0 is a soft edge.
--
--     -- segment_size = 11,
--     -- segment_smoothness = 0.0,
-- }

config.window_background_opacity = 0.88
config.hide_tab_bar_if_only_one_tab = true

-- Fonts
config.font = wezterm.font('JetBrains Mono')
config.font_size = 10.8

-- makes my cursor blink
-- config.default_cursor_style = 'BlinkingBar'

-- Keybidings and remaps
config.disable_default_key_bindings = true

local leader = 'LEADER'
local cmd = 'CMD'
local ctrl = 'CTRL'
local shift = 'SHIFT'
local meta = 'META' -- 'alt' on Windows

local cmd_ctrl = cmd .. '|' .. ctrl
local cmd_shift = cmd .. '|' .. shift
local cmd_meta = cmd .. '|' .. meta
local ctrl_shift = ctrl .. '|' .. shift
local ctrl_meta = ctrl .. '|' .. meta
local shift_meta = shift .. '|' .. meta

config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
    -- Workspaces

    -- Show the launcher in fuzzy selection mode and have it list all workspaces
    -- and allow activating one.
    -- Switch to the default workspace
    {
        key = '1', mods = ctrl_meta, action = act.SwitchToWorkspace { name = 'default', },
    },
    -- Switch to a monitoring workspace, which will have `top` launched into it
    {
        key = 'm',
        mods = ctrl_meta,
        action = act.SwitchToWorkspace {
            name = 'monitoring',
            spawn = {
                args = { 'btm' },
            },
        },
    },
    -- Create a new workspace with a random name and switch to it
    { key = 'i', mods = cmd_meta,  action = act.SwitchToWorkspace },
    -- Show the launcher in fuzzy selection mode and have it list all workspaces
    -- and allow activating one.
    {
        key = '0',
        mods = ctrl_meta,
        action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES', },
    },
    { key = 'n', mods = ctrl_meta, action = act.SwitchWorkspaceRelative(1) },
    { key = 'p', mods = ctrl_meta, action = act.SwitchWorkspaceRelative(-1) },


    -- splitting
    {
        key    = 'v',
        mods   = leader,
        action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }
    },
    {
        key    = 'f',
        mods   = leader,
        action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }
    },
    -- Maximize a pane over others
    {
        key = 'f',
        mods = shift_meta,
        action = wezterm.action.TogglePaneZoomState
    },
    -- rotate panes
    {
        key = 'Space',
        mods = leader,
        action = wezterm.action.RotatePanes 'Clockwise'
    },
    -- show the pane selection mode, but have it swap the active and selected panes
    {
        key = '0',
        mods = leader,
        action = wezterm.action.PaneSelect { mode = 'SwapWithActive', },
    },
    -- Enters the 'Wezterm' copy selecion mode
    {
        key = 'Enter',
        mods = leader,
        action = act.ActivateCopyMode
    },

    {
        key = 'r',
        mods = leader,
        action = act.ReloadConfiguration
    },

    {
        key = 'y',
        mods = leader,
        action = wezterm.action.ShowTabNavigator
    },

    -- Navigation. Don't use the leader, since leader it's an 'operator pending' mode binding, and makes difficult
    -- to navigate more than once without doing to much keystrokes
    { key = 'l', mods = shift_meta, action = act.ActivateTabRelative(1) },
    { key = 'h', mods = shift_meta, action = act.ActivateTabRelative(-1) },

    { key = 'h', mods = ctrl_meta,  action = act.ActivatePaneDirection 'Left', },
    { key = 'l', mods = ctrl_meta,  action = act.ActivatePaneDirection 'Right', },
    { key = 'k', mods = ctrl_meta,  action = act.ActivatePaneDirection 'Up', },
    { key = 'j', mods = ctrl_meta,  action = act.ActivatePaneDirection 'Down', },

    { key = 'h', mods = leader,     action = act.AdjustPaneSize { 'Left', 5 }, },
    { key = 'l', mods = leader,     action = act.AdjustPaneSize { 'Right', 5 }, },
    { key = 'k', mods = leader,     action = act.AdjustPaneSize { 'Up', 5 }, },
    { key = 'j', mods = leader,     action = act.AdjustPaneSize { 'Down', 5 }, },

    { key = 'n', mods = leader,     action = act.SpawnWindow },
    { key = 't', mods = leader,     action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'c', mods = leader,     action = act.CloseCurrentTab { confirm = false } },
    { key = 'x', mods = leader,     action = act.CloseCurrentPane { confirm = false } },
    { key = 'b', mods = leader,     action = act.SendString '\x02', },

    { key = '+', mods = leader,     action = act.IncreaseFontSize },
    { key = '-', mods = leader,     action = act.DecreaseFontSize },
    { key = '¡', mods = leader,     action = act.ResetFontSize },

    { key = 'C', mods = ctrl_shift, action = act.CopyTo 'Clipboard' },
    { key = 'V', mods = ctrl_shift, action = act.PasteFrom 'Clipboard', },
}

-- There are mouse binding to mimc Windows Terminal and let you copy
-- To copy just highlight something and right click. Simple
local mouse_bindings = {
    {
        event = { Down = { streak = 3, button = 'Left' } },
        action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
        mods = 'NONE',
    },
    {
        event = { Down = { streak = 1, button = 'Right' } },
        mods = 'NONE',
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ''
            if has_selection then
                window:perform_action(act.CopyTo('ClipboardAndPrimarySelection'), pane)
                window:perform_action(act.ClearSelection, pane)
            else
                window:perform_action(act({ PasteFrom = 'Clipboard' }), pane)
            end
        end),
    },
}

config.mouse_bindings = mouse_bindings

-- This is used to set an image as my background
--[[ config.background = {
    {
        source = { File = { path = 'C:/Users/someuserboi/Pictures/Backgrounds/theone.gif', speed = 0.2 } },
        opacity = 1,
        width = '100%',
        hsb = { brightness = 0.5 },
    }
} ]]


--[[ config.active_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7
}
]]
config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.75
}

config.window_background_image_hsb = {
    -- Darken the background image by reducing it to 1/3rd
    brightness = 0.3,
    -- You can adjust the hue by scaling its value.
    -- a multiplier of 1.0 leaves the value unchanged.
    hue = 1.0,
    -- You can adjust the saturation also.
    saturation = 1.0,
}

config.use_dead_keys = false
config.scrollback_lines = 5000
config.adjust_window_size_when_changing_font_size = false
config.hide_tab_bar_if_only_one_tab = false

-- config.window_frame = {
--     font = wezterm.font { family = 'Noto Sans', weight = 'Regular' },
-- }
--
config.set_environment_variables = {}

-- Pending Win32 specifics
-- [[
-- allow_win32_input_mode = true
-- ]]


return config
