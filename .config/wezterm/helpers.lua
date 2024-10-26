local wezterm = require 'wezterm'
local action = wezterm.action
local mux = wezterm.mux

--- Switches to a specified workspace, creating it if it does not exist.
-- @param label The label for the workspace, usually derived from the project name.
-- @param child_window The window object where the action is performed.
-- @param child_pane The pane object where the action is performed.
-- @param project A table containing project information including its directory.
local function switch_workspace(label, child_window, child_pane, project)
    -- The SwitchToWorkspace action will switch us to a workspace if it already exists,
    -- otherwise it will create it for us.
    local ws_name = label:match("([^/]+)%)?$")
    child_window:perform_action(action.SwitchToWorkspace {
        name = ws_name,
        spawn = { cwd = project.dir },
    }, child_pane)

    local workspace = mux.get_active_workspace()
    for _, window in ipairs(mux.all_windows()) do
        if window:get_workspace() == workspace then
            local pane = window:active_pane()
            local tab = pane:tab()
            project.cfg(tab, child_pane, window, project.name, project.dir)
        end
    end
end

--- Checks if a given path is a directory.
-- @param path The path to check.
-- @return bool Returns true if the path is a directory, false otherwise.
local function is_dir(path)
    local f = io.popen('test -d "' .. path .. '" && echo true || echo false')
    if not f then
        return false -- If io.popen fails, return false (not a directory)
    end

    local output = f:read('*all')
    f:close()

    if not output then
        return false -- If read fails, return false (not a directory)
    end

    -- Check if the output contains "true"
    return output:match("true") ~= nil
end

--- Default layout function for a project tab.
-- @param tab The tab object to set up.
-- @param pane The pane object to split.
-- @param window The window object containing the tab.
-- @param project_name The name of the project.
-- @param project_dir The directory of the project.
local default_layout = function(tab, pane, window, project_name, project_dir)
    tab:set_title(project_name .. ' - editor')
    pane:split { direction = 'Right', size = 0.3, cwd = project_dir }

    local tab_1 = window:spawn_tab { cwd = project_dir }
    tab_1:set_title(project_name .. ' - lazygit')
end

--- Checks if a directory has project markers (i.e., .git or README.md).
-- @param dir The directory to check for project markers.
-- @return bool Returns true if project markers are found, false otherwise.
local function has_project_marker(dir)
    return is_dir(dir .. '/.git') or #wezterm.glob(dir .. '/README.md') > 0
end

--- Recursively finds projects within a base directory.
-- @param base_dir The base directory to search for projects.
-- @param projects A table that will be populated with found projects.
local function find_projects_recursively(base_dir, projects)
    -- Check if the base directory exists
    if not is_dir(base_dir) then
        return
    end

    -- Iterate over each item in the base directory
    for _, dir in ipairs(wezterm.glob(base_dir .. '/*')) do
        if is_dir(dir) then
            -- Check for project markers in the current directory
            if has_project_marker(dir) then
                local proj_name = dir:match("([^/]+)$") -- Extract the project name
                local project = { name = proj_name, cfg = default_layout, dir = dir, label = '' }
                table.insert(projects, project)
            else
                -- If not a project, recursively search in this directory
                find_projects_recursively(dir, projects)
            end
        end
    end
end

--- Sorts the projects table lexicographically by directory.
-- @param projects The table of projects to be sorted.
local function sort_projects(projects)
    table.sort(projects, function(a, b)
        return a.dir < b.dir
    end)
end

--- Finds and loads projects from a specified user root directory.
-- @param hostname The hostname of the machine, used for environment-specific configurations.
-- @param user_root The root directory where user projects are located.
-- @return table Returns a table of projects with their details and configurations.
local function find_and_load_projects(hostname, user_root)
    local projects = {}

    -- The base directory for projects
    local projects_dir = user_root .. '/code'

    -- Start the recursive search for projects
    find_projects_recursively(projects_dir, projects)
    -- Sort the projects lexicographically by directory
    sort_projects(projects)

    -- Check if it's my job environment and load more projects configuration
    if hostname:match("^PC_ECO") then
        local job_cfg = require 'job_cfg'
        for _, project in ipairs(job_cfg.projects) do
            table.insert(projects, project)
        end
    end

    -- Create a list of project names for the dropdown table
    for _, project in pairs(projects) do
        project.label = project.name .. " (" .. project.dir .. ")"
    end

    return projects
end

return { switch_workspace = switch_workspace, load_projects = find_and_load_projects }

