local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local gears = require("gears")

local theme = {}

theme.base = "#1e1e2e"
theme.text = "#cdd6f4"
theme.surface0 = "#313244"
theme.surface1 = "#45475a"
theme.overlay0 = "#6c7086"
theme.pink = "#f5c2e7"
theme.mantle = "#181825"
theme.blue = "#89b4fa"

theme.font = "jetbrains mono 14"

theme.systray_icon_spacing = 6

theme.fg_normal = theme.text
theme.fg_focus = theme.text
theme.fg_urgent = theme.text
theme.fg_minimize = theme.text

theme.useless_gap = dpi(0)
theme.border_width = dpi(0)
theme.border_normal = theme.blue
theme.border_focus = theme.mantle
theme.border_marked = theme.pink

theme.notification_font = "16"
theme.notification_bg = theme.surface0 .. "55"
theme.notification_fg = theme.text
theme.notification_border_width = dpi(20)
theme.notification_border_color = theme.blue
theme.notification_max_width = 600
theme.notification_icon_size = 150
theme.notification_shape = function(cr, width, height)
	gears.shape.rounded_rect(cr, width, height, dpi(15))
end
theme.menu_height = dpi(25)
theme.menu_width = dpi(200)

theme.wallpaper = "~/.config/awesome/themes/wallpaper3.png"

theme.wibar_bg = theme.surface0
theme.wibar_fg = theme.text
theme.bg_systray = theme.surface1
theme.bg_widget = theme.surface1

return theme
