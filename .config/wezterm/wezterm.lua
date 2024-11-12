-- Pull in the wezterm API
print('Entering the configuration file')
local wezterm = require 'wezterm'
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
local helpers = require 'helpers'
print('Before load projects')
-- The projects that will be shown on the 'projects selector'
local projects = helpers.load_projects(hostname, user_root)

local wsl_domains = wezterm.default_wsl_domains()

for idx, dom in ipairs(wsl_domains) do
  if dom.name == 'WSL:Ubuntu-24.04' then
    dom.default_prog = { 'zsh' }
  end
end

config.wsl_domains = wsl_domains

print('After load projects')

-- https://wezfurlong.org/wezterm/config/lua/gui-events/gui-startup.html
-- my cfg contains custom configuration for launch the workspaces via -- workspaces and NOT --workspaces (wezterm built in one)
wezterm.on('gui-startup', function(cmd)
    print("gui-startup invoked")
    -- allow `wezterm start -- something` to affect what we spawn in our initial window

    local _, pane, window = mux.spawn_window({})
    local gui_window = window:gui_window()

    if cmd then
        local args = cmd.args
        if args[1] == 'workspace' then
            for _, project in pairs(projects) do
                if project.name == args[2] then
                    -- TODO: toast notification?
                    local label = project.name
                    helpers.switch_workspace(label, gui_window, pane, project)
                end
            end
        end
    end
    print('gui-startup cmd finished')

    gui_window:maximize()
    print('gui-startup finished')
end)

-- Launch Menu
local launch_menu = require 'launch_menu'
launch_menu.apply_to_config(config)

-- Appeareance
local appeareance = require 'appeareance'
appeareance.apply_to_config(config)

-- The powerline cfg
require 'powerline'

-- Keybidings and remaps
local keymaps = require 'keymaps'
keymaps.apply_to_config(config, projects, helpers.switch_workspace)

-- Mouse cfg
local mouse = require 'mouse'
mouse.apply_to_config(config)

-- Other general cfg
config.window_close_confirmation = 'NeverPrompt'
config.set_environment_variables = {}

return config
