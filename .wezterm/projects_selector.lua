local wezterm = require 'wezterm'

local function project_picker(projects, switch_workspace_callback)
    local dropdown_choices = {}

    -- Create a list of project names for concatenation
    for _, project in pairs(projects) do
        project.label = project.name .. " (" .. project.dir .. ")"
        table.insert(dropdown_choices, { label = project.label }) -- Prepare choices for the selector
    end

    -- The InputSelector action presents a modal UI for choosing between a set of options within WezTerm.
    return wezterm.action.InputSelector {
        title = 'Projects',
        choices = dropdown_choices,
        fuzzy = true,
        action = wezterm.action_callback(function(child_window, child_pane, id, label)
            if not label then return end

            for _, project in pairs(projects) do
                if project.label == label then
                    switch_workspace_callback(label, child_window, child_pane, project)
                end
            end
        end),
    }
end

return { selector = project_picker }
