-- Wezterm API
local wezterm = require("wezterm")
local act = wezterm.action
local config = wezterm.config_builder()

-- Customsisations
config.default_cursor_style = 'SteadyBar'
config.font = wezterm.font("Vertex Mono NF")
config.font_size = 19
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.enable_tab_bar = true
config.line_height = 1.15
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.975
config.macos_window_background_blur = 10

-- Colorscheme
config.colors = {
	foreground = "#CBE0F0",
	background = "#042333",
	cursor_bg = "#AAFF00",
	cursor_border = "#000000",
	cursor_fg = "#AAFF00",
	selection_bg = "#033259",
	selection_fg = "#CBE0F0",
	ansi = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#0FC5ED", "#a277ff", "#24EAF7", "#24EAF7" },
	brights = { "#214969", "#E52E2E", "#44FFB1", "#FFE073", "#A277FF", "#a277ff", "#24EAF7", "#24EAF7" },
}

-- Keybinds (MacOS translated to UNIX)
config.keys = {
    -- CMD + Left = Go to start of line (Ctrl+A)
    { key = 'LeftArrow', mods = 'CMD', action = act.SendString '\x01' },
    -- CMD + Right = Go to end of line (Ctrl+E)
    { key = 'RightArrow', mods = 'CMD', action = act.SendString '\x05' },
    -- CMD + Backspace = Delete whole line (Ctrl+U)
    { key = 'Backspace', mods = 'CMD', action = act.SendString '\x15' },
    -- OPTION + Left = Go one word back (Alt+B)
    { key = 'LeftArrow', mods = 'OPT', action = act.SendString '\x1bb' },
    -- OPTION + Right = Go one word forward (Alt+F)
    { key = 'RightArrow', mods = 'OPT', action = act.SendString '\x1bf' },
    -- OPTION + Backspace = Delete preceding word (Ctrl+W)
    { key = 'Backspace', mods = 'OPT', action = act.SendString '\x17' },
}
 
return config
