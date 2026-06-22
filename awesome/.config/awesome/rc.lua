pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
require("awful.hotkeys_popup.keys")
local beautiful = require("beautiful")
local naughty = require("naughty")

if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end

beautiful.init("~/.config/awesome/themes/default.lua")

-- init vars
TERMINAL = "kitty"
EDITOR = os.getenv("EDITOR") or "vim"
EDITOR_CMD = TERMINAL .. " -e " .. EDITOR
MODKEY = "Mod4"
ALT = "Mod1"
SHIFT = "Shift"
CONTROL = "Control"
HOME = os.getenv("HOME")

require("keymaps")
require("rules")

awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.max,
}

local function set_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	set_wallpaper(s)
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[3])
	require("bar")(s)
end)

client.connect_signal("manage", function(c)
	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		awful.placement.no_offscreen(c)
	end
end)

client.connect_signal("property::name", function(c)
	if c.class == "Firefox" or c.class == "firefox" then
		local s = c.screen
		if c.first_tag then
			c.first_tag:view_only()
		end
		client.focus = c
		c:raise()
	end
end)

-- autostart
awful.spawn.with_shell("picom")
awful.spawn.with_shell("nm-applet")
awful.spawn.with_shell("blueman-applet")
awful.spawn.with_shell("sudo -n " .. HOME .. "/Desktop/Throne/Throne")
-- awful.spawn.with_shell(terminal .. " --class btop" .. " -e" .. " btop")
awful.spawn.with_shell("steam")
awful.spawn.with_shell("Telegram")
awful.spawn.with_shell("discord")
awful.spawn.with_shell("betterbird")
awful.spawn.with_shell("greenclip daemon")
awful.spawn.with_shell("superproductivity")
awful.spawn.with_shell("pgrep -x firefox >/dev/null || firefox & disown")
-- awful.spawn.with_shell("ps x | grep -v grep | grep -q obsidian || obsidian")
