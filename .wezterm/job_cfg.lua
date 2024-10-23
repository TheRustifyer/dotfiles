-- .wezterm_job_cfg.lua
local wezterm = require 'wezterm'
local mux = wezterm.mux

-- base Inergy projects paths
local inergy_projects = wezterm.home_dir .. "/code/ecomt/inergy"

local inergymb = function(tab, pane, window, project_name, project_dir)
    tab:set_title(project_name)
    pane:split { direction = 'Right', size = 0.3, cwd = project_dir, args = {'lazygit'} }

    -- Manually spawn the 'nocode' repository of the mic-inergypaas
    local mic_inergypaas = 'mic-inergypaasdeployment'
    local inergypaas_dir = inergy_projects .. '/' .. mic_inergypaas

    local tab_1 = window:spawn_tab { cwd = inergypaas_dir, }
    tab_1:set_title(mic_inergypaas)
    local tab_1_pane = tab_1:active_pane()
    tab_1_pane:split { direction = 'Right', size = 0.3, cwd = inergypaas_dir, args = {'lazygit'} }
end

local projects = {
    inergymb = { name = 'mic-inergymb', cfg = inergymb, dir = inergy_projects .. '/mic-inergymb', label = '' },
    inergyws = { name = 'wsc-inergyws', cfg = inergymb, dir = inergy_projects .. '/wsc-inergyws', label = '' },
}

return { projects = projects, }
