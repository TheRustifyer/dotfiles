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
        spawn = {
            cwd = project.dir,
            domain = project.domain
        },
    }, child_pane)

    local workspace = mux.get_active_workspace()
    for _, window in ipairs(mux.all_windows()) do
        if window:get_workspace() == workspace then
            local pane = window:active_pane()
            local tab = pane:tab()
            project.cfg(tab, child_pane, window, project.dir, project.domain)
        end
    end
end

local function get_wsl_distros()
    -- Query the default WSL distribution
    local _, stdout, stderr = wezterm.run_child_process({ "wsl", "-l", "--quiet", "--all" })
    if stdout then
        return stdout
    else
        wezterm.log_error("Failed to get WSL distributions: " .. (stderr or "unknown error"))
        return nil
    end
end

local function get_wsl_default_distro()
    local wsl_distros = get_wsl_distros()

    -- Find the default WSL distribution (first line in the output)
    local distro_name = wsl_distros ~= nil and wsl_distros:match("^[^\r\n]+") or nil
    print("Default distro name: " .. distro_name)
    if not distro_name then
        wezterm.log_info("No WSL distribution found")
        return nil
    end
    return distro_name
end

local function get_wsl_unc_path(distro_name)
    local sanitized_distro_name = distro_name ~= nil and distro_name:gsub("[^%w%-]", "") or get_wsl_default_distro()
    return sanitized_distro_name and "//wsl.localhost/" .. sanitized_distro_name or nil
end

local function strip_wsl_prefix(unc_path)
  -- Match and remove the prefix for WSL UNC paths
  local stripped_path = unc_path:gsub("^//wsl%.localhost/[^/]+", "")
  return stripped_path
end

local function path_to_forward_slashes(path)
    return path:gsub("\\", "/")
end

local function sanitize_str_null_term(input)
    return input:gsub("%z", "") -- Removes all `\0` characters
end

local function get_project_name_from_path(path)
     return path:match("([^/]+)$")
end

return {
    get_project_name_from_path = get_project_name_from_path,
    sanitize_str_null_term = sanitize_str_null_term,
    path_to_forward_slashes = path_to_forward_slashes,
    switch_workspace = switch_workspace,
    get_wsl_unc_path = get_wsl_unc_path,
    strip_wsl_prefix = strip_wsl_prefix,
    get_wsl_default_distro = get_wsl_default_distro,
    get_wsl_distros = get_wsl_distros
}
