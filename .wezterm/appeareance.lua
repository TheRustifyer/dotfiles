local wezterm = require 'wezterm'

local config = {}

-- This is used to make my foreground (text, etc) brighter than my background
config.foreground_text_hsb = {
    hue = 1.0,
    saturation = 1.0,
    brightness = 1.0,
}

-- Color scheme, Wezterm has 100s of them you can see here:
-- https://wezfurlong.org/wezterm/colorschemes/index.html
-- config.color_scheme = 'Oceanic Next (Gogh)'
config.color_schemes = {
    -- ['Oceanic Next (Gogh)'] = {
    ['thwump (terminal.sexy) '] = {
        -- background = 'black',
        -- TODO cursor opts non working
        cursor_bg = 'white',
        cursor_border = '#8b8198',
        cursor_fg = '#8b8198',
    },
}
-- config.color_scheme = 'thwump (terminal.sexy) '
-- config.color_scheme = '3024 Night (Gogh)'
config.window_frame = {
    font = wezterm.font { family = 'Roboto', weight = 'Bold' },
    -- The size of the font in the tab bar.
    font_size = 10.0,
    active_titlebar_bg = '#333333',
    inactive_titlebar_bg = '#333333',
}

config.colors = {
    tab_bar = {
        -- The color of the inactive tab bar edge/divider
        inactive_tab_edge = '#575757',
    },
}

config.window_background_opacity = 0.82
config.hide_tab_bar_if_only_one_tab = true

-- Fonts
config.font = wezterm.font('JetBrains Mono')
config.font_size = 10.8

-- makes my cursor blink
-- config.default_cursor_style = 'BlinkingBar'-- This is used to set an image as my background
--[[ config.background = {
    {
        source = { File = { path = 'C:/Users/user/Pictures/Backgrounds/theone.gif', speed = 0.2 } },
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

-- config.window_background_gradient = {
--     -- orientation = 'Vertical',
--     orientation = {
--         Radial = {
--             cx = 0.75,
--             cy = 0.75,
--             radius = 2.25,
--         },
--     },
--     -- Specifies the set of colors that are interpolated in the gradient.
--     -- Accepts CSS style color specs, from named colors, through rgb
--     -- strings and more
--     --[[ colors = {
--         '#0f0c29',
--         '#302b63',
--         '#24243e',
--     }, -- Cold
--     colors = { '#EEBD89', '#D13ABD' }, -- Calid ]]
--     -- A list of presets is shown in a section below.
--     -- https://wezfurlong.org/wezterm/config/lua/config/window_background_gradient.html?h=preset#presets
--     preset = "Viridis",
--     -- preset = "Magma",
--     interpolation = 'Linear',
--     blend = 'Rgb',
--     noise = 14,
--     -- segment_size = 11,
--     -- segment_smoothness = 0.0,
-- }

return config
