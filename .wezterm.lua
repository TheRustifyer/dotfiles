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

-- These are vars to put things in later (i dont use em all yet)
local keys = {}
local mouse_bindings = {}
local launch_menu = {} -- TODO: Pending to configure it
config.launch_menu = launch_menu

local is_windows = os.getenv("WINDIR") ~= nil
if is_windows then
    config.default_prog = { os.getenv('USERPROFILE') .. '/AppData/Local/Programs/Git/usr/bin/zsh.exe' } -- TODO replace it for the MSYS2 one
else
    config.default_prog = { '/usr/bin/zsh' }
end

-- Color scheme, Wezterm has 100s of them you can see here:
-- https://wezfurlong.org/wezterm/colorschemes/index.html
-- config.color_scheme = 'Oceanic Next (Gogh)'
config.color_schemes = {
    -- ['Oceanic Next (Gogh)'] = {
    ['thwump (terminal.sexy) '] = {
        background = 'black',
        -- TODO cursor opts non working
        cursor_bg = "white",
        cursor_border = "#8b8198",
        cursor_fg = "#8b8198",
    },
}
config.window_background_opacity = 0.82
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
    { key = 'i', mods = cmd_meta, action = act.SwitchToWorkspace },
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
        key = 'z',
        mods = shift_meta,
        action = wezterm.action.TogglePaneZoomState
    },
    -- rotate panes
    {
        key = 'Space',
        mods = leader,
        action = wezterm.action.RotatePanes "Clockwise"
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
    { key = 'l', mods = shift_meta,  action = act.ActivateTabRelative(1) },
    { key = 'h', mods = shift_meta,  action = act.ActivateTabRelative(-1) },

    { key = 'h', mods = ctrl_meta,   action = act.ActivatePaneDirection 'Left', },
    { key = 'l', mods = ctrl_meta,   action = act.ActivatePaneDirection 'Right', },
    { key = 'k', mods = ctrl_meta,   action = act.ActivatePaneDirection 'Up', },
    { key = 'j', mods = ctrl_meta,   action = act.ActivatePaneDirection 'Down', },

    { key = 'h', mods = leader,     action = act.AdjustPaneSize { 'Left', 5 }, },
    { key = 'l', mods = leader,     action = act.AdjustPaneSize { 'Right', 5 }, },
    { key = 'k', mods = leader,     action = act.AdjustPaneSize { 'Up', 5 }, },
    { key = 'j', mods = leader,     action = act.AdjustPaneSize { 'Down', 5 }, },

    { key = 'n', mods = leader,     action = act.SpawnWindow },
    { key = 't', mods = leader,     action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'w', mods = leader,     action = act.CloseCurrentTab { confirm = false } },
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
mouse_bindings = {
    {
        event = { Down = { streak = 3, button = 'Left' } },
        action = wezterm.action.SelectTextAtMouseCursor 'SemanticZone',
        mods = 'NONE',
    },
    {
        event = { Down = { streak = 1, button = "Right" } },
        mods = "NONE",
        action = wezterm.action_callback(function(window, pane)
            local has_selection = window:get_selection_text_for_pane(pane) ~= ""
            if has_selection then
                window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
                window:perform_action(act.ClearSelection, pane)
            else
                window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
            end
        end),
    },
}

config.mouse_bindings = mouse_bindings

-- This is used to make my foreground (text, etc) brighter than my background
config.foreground_text_hsb = {
    hue = 1.0,
    saturation = 1.2,
    brightness = 1.5,
}

-- This is used to set an image as my background
--[[ config.background = {
    {
        source = { File = { path = 'C:/Users/someuserboi/Pictures/Backgrounds/theone.gif', speed = 0.2 } },
        opacity = 1,
        width = "100%",
        hsb = { brightness = 0.5 },
    }
} ]]

config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7
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
