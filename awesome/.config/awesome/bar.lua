local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")
local volume_control = require("widgets/volume-control")

local function wrap_bg(widget)
	c = wibox.container.background(widget, nil, nil)
	c.bg = beautiful.bg_widget
	c.fg = beautiful.text
	return c
end

local session_menu = {
	{
		"",
		function()
			awful.spawn.with_shell("systemctl suspend")
		end,
	},
	{
		"",
		function()
			awful.spawn.with_shell("reboot")
		end,
	},
	{
		"",
		function()
			awesome.quit()
		end,
	},
	{
		"⭘",
		function()
			awful.spawn.with_shell("shutdown now")
		end,
	},
}

local main_menu = awful.menu({
	items = session_menu,
	theme = { width = 68, font = "16" },
})

local exit_widget = wibox.widget({
	text = "⏻ ",
	font = "25",
	widget = wibox.widget.textbox,
})
exit_widget:buttons(gears.table.join(awful.button({}, 1, function()
	main_menu:toggle()
end)))

volumecfg = volume_control({
	device = "pulse",
	rclick = TERMINAL .. " --class pulsemixer" .. " -e " .. HOME .. "/Desktop/pulsemixer",
	step = "10%",
	widget_text = {
		on = " %3d%%", -- three digits, fill with leading spaces
		off = " Muted",
	},
})
local space_widget = wrap_bg(wibox.widget({
	markup = " ",
	widget = wibox.widget.textbox,
}))
local layout = awful.widget.keyboardlayout()
layout.widget:set_font("Jetbrains Mono 20")

function set_up(s)
	s.mywibox = awful.wibar({ position = "top", screen = s, height = 25, visible = false })

	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		expand = "none",
		{
			layout = wibox.layout.fixed.horizontal,
			space_widget,
			wrap_bg(wibox.widget.systray()),
			space_widget,
			wrap_bg(volumecfg.widget),
			space_widget,
		},
		{
			layout = wibox.layout.fixed.horizontal,
			space_widget,
			wrap_bg(wibox.widget({
				format = "%d %H:%M:%S",
				widget = wibox.widget.textclock,
				refresh = 1,
				font = "jetbrains mono 16",
			})),
			space_widget,
		},
		{
			layout = wibox.layout.fixed.horizontal,
			wrap_bg(layout),
			wrap_bg(exit_widget),
		},
	})
end

return set_up
