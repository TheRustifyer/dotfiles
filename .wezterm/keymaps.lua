local wezterm = require 'wezterm'
local act = wezterm.action

local config = {}

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

local function load_keymaps(wezterm_cfg, projects, switch_workspace_callback)
    return {
        -- Workspaces
        {
            key = 'p',
            mods = 'LEADER',
            -- Present in to our project picker
            action = wezterm.action_callback(function(win, pane)
                local _, project_picker = pcall(dofile, wezterm_cfg .. "/projects_selector.lua")

                -- Create the InputSelector action
                local selector_action = project_picker.selector(projects, switch_workspace_callback)

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
end

return {
    leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 },
    load_keymaps = load_keymaps
}
