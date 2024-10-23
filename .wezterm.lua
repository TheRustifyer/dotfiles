-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

-- This will hold the configuration.
local config = wezterm.config_builder()

-- The declared hostname of the current machine
local hostname = wezterm.hostname()
-- The user's home directory
local user_root = wezterm.home_dir
-- The lua modules with the helpers for the configuration
local wezterm_cfg = user_root .. '/.wezterm'

-- Loading the helpers
local status, helpers = pcall(dofile, wezterm_cfg .. "/helpers.lua")
if not status then
    wezterm.log_error("Unable to load the helpers: " .. helpers)
end

-- The projects that will be shown on the 'projects selector'
local projects = helpers.load_projects(hostname, user_root)

-- https://wezfurlong.org/wezterm/config/lua/gui-events/gui-startup.html
wezterm.on('gui-startup', function(cmd)
    -- allow `wezterm start -- something` to affect what we spawn in our initial window
    local args = cmd and cmd.args or {}
    -- TODO: pass the args to launch the workspace
    local tab, pane, window = mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)

wezterm.on('update-right-status', function(window, pane)
    window:set_right_status(window:active_workspace())
end)

-- Launch Menu
local status, launch_menu = pcall(dofile, wezterm_cfg .. "/launch_menu.lua")
if not status then
    wezterm.log_error("Unable to load the launch menu: " .. launch_menu)
end

config.window_close_confirmation = 'NeverPrompt'

config.launch_menu = launch_menu.menu
config.default_prog = launch_menu.default_prog

-- Appeareance
local status, appeareance = pcall(dofile, wezterm_cfg .. "/appeareance.lua")
if not status then
    wezterm.log_error("Unable to load the appeareance: " .. appeareance)
end

config.foreground_text_hsb = appeareance.foreground_text_hsb
config.color_schemes = appeareance.color_schemes
config.window_frame = appeareance.window_frame
config.colors = appeareance.colors

config.window_background_opacity = appeareance.window_background_opacity
config.hide_tab_bar_if_only_one_tab = appeareance.hide_tab_bar_if_only_one_tab

config.inactive_pane_hsb = appeareance.inactive_pane_hsb
config.window_background_image_hsb = appeareance.window_background_image_hsb

-- Fonts
config.font = appeareance.font
config.font_size = appeareance.font_size

-- Keybidings and remaps
config.disable_default_key_bindings = true

local status, powerline = pcall(dofile, wezterm_cfg .. "/powerline.lua")
if not status then
    wezterm.log_error("Unable to load the powerline")
end

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
    {
        key = 'p',
        mods = 'LEADER',
        -- Present in to our project picker
        action = wezterm.action_callback(function(win, pane)
            local _, project_picker = pcall(dofile, wezterm_cfg .. "/projects_selector.lua")

            -- Create the InputSelector action
            local selector_action = project_picker.selector(projects, helpers.switch_workspace)

            -- Perform the action on the window
            win:perform_action(selector_action, pane)
        end)
    },

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

config.enable_scroll_bar = true
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
