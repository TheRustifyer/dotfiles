-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- These are vars to put things in later (i dont use em all yet)
local keys = {}
local mouse_bindings = {}
local launch_menu = {} -- TODO: Pending to configure it
config.launch_menu = launch_menu

-- local is_windows = vim.loop.os_uname().sysname == 'Windows_NT'
local is_windows = os.getenv("WINDIR") ~= nil
if is_windows then
    config.default_prog = { os.getenv('USERPROFILE') .. '/AppData/Local/Programs/Git/usr/bin/zsh.exe' }
else
    config.default_prog = { '/usr/bin/zsh' }
end

-- Color scheme, Wezterm has 100s of them you can see here:
-- https://wezfurlong.org/wezterm/colorschemes/index.html
config.color_scheme = 'Oceanic Next (Gogh)'
config.color_schemes = {
    ['Oceanic Next (Gogh)'] = {
        background = 'black',
    },
}
config.window_background_opacity = 0.8

-- Fonts
config.font = wezterm.font('Hack Nerd Font Mono')
config.font_size = 11

-- makes my cursor blink
-- config.default_cursor_style = 'BlinkingBar'

-- Keybidings and remaps
config.disable_default_key_bindings = true

-- this adds the ability to use ctrl+v to paste the system clipboard
config.keys = {
    { key = 'l',     mods = 'CMD|SHIFT',  action = act.ActivateTabRelative(1) },
    { key = 'h',     mods = 'CMD|SHIFT',  action = act.ActivateTabRelative(-1) },
    { key = 'j',     mods = 'CMD',        action = act.ActivatePaneDirection 'Down', },
    { key = 'k',     mods = 'CMD',        action = act.ActivatePaneDirection 'Up', },
    { key = 'Enter', mods = 'CMD',        action = act.ActivateCopyMode },
    { key = 'R',     mods = 'SHIFT|CTRL', action = act.ReloadConfiguration },
    { key = '+',     mods = 'CTRL',       action = act.IncreaseFontSize },
    { key = '-',     mods = 'CTRL',       action = act.DecreaseFontSize },
    { key = '0',     mods = 'CTRL',       action = act.ResetFontSize },
    { key = 'C',     mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
    { key = 'N',     mods = 'SHIFT|CTRL', action = act.SpawnWindow },
    {
        key = 'T',
        mods = 'SHIFT|CMD',
        action = act.SpawnTab 'CurrentPaneDomain',
    },
    { key = 'U',          mods = 'SHIFT|CTRL', action = act.CharSelect { copy_on_select = true, copy_to = 'ClipboardAndPrimarySelection' } },
    { key = 'V',          mods = 'CTRL|SHIFT', action = act.PasteFrom 'Clipboard' },
    { key = 'PageUp',     mods = 'CTRL',       action = act.ActivateTabRelative(-1) },
    { key = 'PageDown',   mods = 'CTRL',       action = act.ActivateTabRelative(1) },
    { key = 'LeftArrow',  mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Left' },
    { key = 'RightArrow', mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Right' },
    { key = 'UpArrow',    mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Up' },
    { key = 'DownArrow',  mods = 'SHIFT|CTRL', action = act.ActivatePaneDirection 'Down' },
    { key = 'f',          mods = 'CMD',        action = act.SplitVertical { domain = 'CurrentPaneDomain' }, },
    { key = 'd',          mods = 'CMD',        action = act.SplitHorizontal { domain = 'CurrentPaneDomain' }, },
    { key = 'h',          mods = 'CMD',        action = act.ActivatePaneDirection 'Left', },
    { key = 'l',          mods = 'CMD',        action = act.ActivatePaneDirection 'Right', },
    { key = 't',          mods = 'CMD',        action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'w',          mods = 'CMD',        action = act.CloseCurrentTab { confirm = false } },
    { key = 'x',          mods = 'CMD',        action = act.CloseCurrentPane { confirm = false } },
    { key = 'b',          mods = 'CMD|CTRL',   action = act.SendString '\x02', },
    -- { key = 'p',          mods = 'LEADER',      action = act.PasteFrom, }, --TODO: wrong opt
    {
        key = 'k',
        mods = 'CTRL|ALT',
        action = act.Multiple
            {
                act.ClearScrollback 'ScrollbackAndViewport',
                act.SendKey { key = 'L', mods = 'CTRL' }
            }
    },
    { key = 'r', mods = 'CMD', action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false, }, },
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


-- and finally, return the configuration to wezterm
return config
