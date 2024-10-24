local wezterm = require 'wezterm'

local launch_menu = {}
local default_prog = {}

if wezterm.target_triple == 'x86_64-pc-windows-msvc' then
    local msys2_clang64 = { 'cmd.exe ', '/k',
        'C:/msys64/msys2_shell.cmd -defterm -here -no-start -clang64 -use-full-path -shell zsh' }
    local msys2_mingw64 = { 'cmd.exe ', '/k',
        'C:/msys64/msys2_shell.cmd -defterm -here -no-start -mingw64 -use-full-path -shell zsh' }
    local msys2 = { 'cmd.exe ', '/k',
        'C:/msys64/msys2_shell.cmd -defterm -here -no-start -msys -use-full-path -shell zsh' }

    table.insert(launch_menu, {
        label = 'MSYS2 CLANG64',
        args = msys2_clang64,
    })
    table.insert(launch_menu, {
        label = 'MSYS2 MINGW64',
        args = msys2_mingw64,
    })
    table.insert(launch_menu, {
        label = 'msys2',
        args = msys2,
    })
    table.insert(launch_menu, {
        label = 'PowerShell',
        args = { 'C:/WINDOWS/System32/WindowsPowerShell/v1.0/powershell', '-nol' },
    })

    default_prog = msys2_mingw64
else
    default_prog = { '/usr/bin/zsh' }
end

return {
    menu = launch_menu,
    default_prog = default_prog
}
