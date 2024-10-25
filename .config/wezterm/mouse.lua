local wezterm = require 'wezterm'
local act = wezterm.action

local module = {}
function module.apply_to_config(config)
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
end

return module
