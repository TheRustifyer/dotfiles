local wezterm = require 'wezterm'
local action = wezterm.action
local mux = wezterm.mux

local function switch_workspace(label, child_window, child_pane, project)
    -- The SwitchToWorkspace action will switch us to a workspace if it already exists,
    -- otherwise it will create it for us.
    local ws_name = label:match("([^/]+)$"):gsub(".?$", "")
    child_window:perform_action(action.SwitchToWorkspace {
        name = ws_name,
        spawn = { cwd = project.dir },
    }, child_pane)

    local workspace = mux.get_active_workspace()
    for _, window in ipairs(mux.all_windows()) do
        if window:get_workspace() == workspace then
            local pane = window:active_pane()
            local tab = pane:tab()
            project.cfg(tab, pane, window, project.name, project.dir)
        end
    end
end

local function find_and_load_projects(hostname, user_root)
    local projects = {}

    -- Check if its my job enviroment, and load more projects configuration
    if hostname:match("^PC_ECO") then
        local dotfile_path = user_root .. "/.wezterm/job_cfg.lua"
        local status, job_cfg = pcall(dofile, dotfile_path)
        projects = job_cfg.projects
    end

    return projects
end

return { switch_workspace = switch_workspace, load_projects = find_and_load_projects }
