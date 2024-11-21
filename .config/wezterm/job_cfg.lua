local helpers = require 'helpers'

-- .wezterm_job_cfg.lua
local inergymb = function(tab, pane, window, project_dir, domain)
    local sanitized_project_dir = helpers.sanitize_str_null_term(project_dir)
    local project_name = helpers.get_project_name_from_path(sanitized_project_dir)
    local lazygit = ('lazygit'):gsub("%z", "")

    tab:set_title(project_name)
    pane:split { direction = 'Right', size = 0.3, cwd = project_name, args = { lazygit }, domain = domain }

    -- Manually spawn the 'nocode' repository of the mic-inergypaas
    local mic_inergypaas = 'mic-inergypaasdeployment'
    local inergypaas_dir = '/home/therustifyer/code/ecomt/inergy' .. '/' .. mic_inergypaas

    local tab_2 = window:spawn_tab { cwd = inergypaas_dir, domain = domain }
    tab_2:set_title(mic_inergypaas)
    local tab_2_pane = tab_2:active_pane()
    tab_2_pane:split { direction = 'Right', size = 0.3, cwd = inergypaas_dir, args = { lazygit }, domain = domain }
end

local function job_projects(user_root)
    local inergy_projects = user_root .. '/home/therustifyer/code/ecomt/inergy'
    local domain = { DomainName = 'WSL:Ubuntu-24.04' }
    print("Inergy projects: " .. inergy_projects)
    local iproj_glob = require 'wezterm'.glob(inergy_projects .. '/*')
    print(iproj_glob)
    -- TODO: get them with the loader or similar?
    local sinergy_projects = helpers.strip_wsl_prefix(inergy_projects)
    local projects = {
        inergymb = { name = 'mic-inergymb', cfg = inergymb, dir = sinergy_projects .. '/mic-inergymb', domain = domain },
        inergyws = { name = 'wsc-inergyws', cfg = inergymb, dir = sinergy_projects .. '/wsc-inergyws', domain = domain },
    }
    return projects
end

return { projects = job_projects, }
