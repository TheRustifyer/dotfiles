-- Module with procedures to load code projects into a GUI selector (leader + P)

local wezterm = require 'wezterm'
local helpers = require 'helpers'

-- Typicall directories on my structure of dirs for organizing repos
CODE_DIR = '/code'
GIT_DIR = '/.git'
GITHUB_DIR = '/.github'
README_FILE = '/README.md'
LAZYGIT = 'lazygit'
CURRENT_PANE_DOMAIN = 'CurrentPaneDomain'

local job_code_projects_path = os.getenv('JOB_PROJECTS_CODE_DIR') or ''

-- Locals from constants

--- Default layout function for a project tab.
-- @param tab The tab object to set up.
-- @param pane The pane object to split.
-- @param window The window object containing the tab.
-- @param project_dir The directory of the project.
local default_layout = function(tab, pane, window, project_dir, domain)
    local sanitized_project_dir = helpers.sanitize_str_null_term(project_dir)
    local project_name = helpers.get_project_name_from_path(sanitized_project_dir)

    tab:set_title(project_name .. ' - editor')
    pane:split { direction = 'Right', size = 0.3, args = { LAZYGIT }, cwd = sanitized_project_dir, domain = domain }

    local tab_1 = window:spawn_tab { cwd = sanitized_project_dir, domain = domain }
    tab_1:set_title(project_name .. ' - ' .. LAZYGIT)
end

--- Checks if a directory is a git project
-- @param dir The directory to check for .git markers folders
-- @return bool Returns true if project markers for a git-based project are found, false otherwise
local function is_git_project(dir)
    return #wezterm.glob(dir .. GIT_DIR) > 0 or
        #wezterm.glob(dir .. GITHUB_DIR) > 0
end

--- Checks if a directory has project markers (i.e., .git, README.md, ...).
-- @param dir The directory to check for project markers.
-- @return bool Returns true if project markers are found, false otherwise.
local function has_project_marker(dir)
    return is_git_project(dir) or #wezterm.glob(dir .. README_FILE) > 0
end

--- Recursively finds projects within a base directory.
-- @param base_dir The base directory to search for projects.
-- @param projects A table that will be populated with found projects.
-- @param domain A table 'Domain' object which contains the target domain for looking for the projects
-- @param depth A counter of the actual number of recursive calls made for the directory parent hierarchy found dirs
local function find_projects(base_dir, projects, domain, depth)
    local recursion_depth = depth or 0 -- Default depth to 0 if not provided
    local rdomain = domain or CURRENT_PANE_DOMAIN

    -- Retrieve all directories/files in the base directory
    local glob_dirs = wezterm.glob(helpers.sanitize_str_null_term(base_dir) .. '/*') or {}

    for _, dir in ipairs(glob_dirs) do
        local dir_recursion_level = recursion_depth + 1
        local proj_name = helpers.get_project_name_from_path(dir) -- Extract the project name
        local sproj_dir = rdomain ~= CURRENT_PANE_DOMAIN and helpers.strip_wsl_prefix(dir) or dir
        local is_git = is_git_project(dir)

        -- Add directories at level 2 or directories with project markers
        if has_project_marker(dir) or dir_recursion_level == 2 then
            local project = {
                name = proj_name,
                cfg = default_layout,
                dir = sproj_dir,
                domain = rdomain,
                git = is_git
            }
            table.insert(projects, project)
        end

        -- Recurse into subdirectories if below level 2
        if dir_recursion_level < 2 or (string.find(dir, job_code_projects_path, 4, true) and dir_recursion_level < 3) then
            find_projects(dir, projects, domain, dir_recursion_level) -- Pass incremented depth
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
local function find_and_load_projects(user_root)
    local projects = {}
    local projects_base_dir = user_root .. CODE_DIR

    -- Start the search for projects
    find_projects(projects_base_dir, projects)

    -- TODO: do the same but for all the WSL distributions, automatically getting the
    -- domain name instead of hardcoding them

    -- The base directory for code projects in the default WSL distro (if present)
    local wsl_unc_path = helpers.get_wsl_unc_path() or ''
    local wsl_projects = wsl_unc_path .. '/home/therustifyer/' .. CODE_DIR
    if wsl_unc_path ~= '' then
        local domain = { DomainName = 'WSL:Ubuntu-24.04' }
        find_projects(wsl_projects, projects, domain)
    end

    -- Sort the projects lexicographically by directory
    sort_projects(projects)

    -- Create a list of project names for the dropdown table
    for _, project in pairs(projects) do
        project.label = project.name .. " (" .. project.dir ..
            " [git: " .. (project.git and '✅' or '❌') .. "]" .. ")"
    end

    return projects
end

return { load_projects = find_and_load_projects }
