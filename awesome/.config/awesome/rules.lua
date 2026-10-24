local awful = require("awful")
local beautiful = require("beautiful")
-- local ruled = require("ruled")

resize = function(c)
	local screen_geometry = c.screen.workarea
	local width = 0.6
	local height = 0.6
	c:geometry({
		width = screen_geometry.width * width,
		height = screen_geometry.height * height,
	})
	awful.placement.centered(c, { honor_workarea = true })
end

awful.rules.rules = {
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},

			name = {
				"Event Tester",
			},
			role = {
				"pop-up",
			},
		},
		properties = { floating = true },
	},

	{ rule = { class = "firefox" }, properties = { screen = 1, tag = "2" } },
	{
		rule_any = { class = { "Telegram", "discord", "Mail", "eu.betterbird.Betterbird", "zoom" } },
		properties = { screen = 1, tag = "3" },
	},
	{ rule = { name = "Steam" }, properties = { screen = 1, tag = "4" } },
	{ rule = { class = "steam" }, properties = { screen = 1, tag = "4" } },

	{ rule = { name = "obsidian" }, properties = { screen = 1, tag = "6" } },
	{ rule = { class = "superproductivity" }, properties = { screen = 1, tag = "6" } },

	{
		rule_any = { class = { "libreoffice", "libreoffice-writer", "Soffice", "soffice" } },
		properties = { screen = 1, tag = "5" },
	},
	{ rule_any = { class = { "Gimp", "gimp" } }, properties = { screen = 1, tag = "5" } },
	{ rule = { class = "btop" }, properties = { screen = 1, tag = "8" } },
	{
		rule_any = { class = { "Happ", "Throne" } },
		properties = { screen = 1, tag = "9" },
	},

	{
		rule_any = {
			class = {
				"pulsemixer",
				"Nm-connection-editor",
				"Network Connections",
				"Nm-applet",
				"Blueman-manager",
			},
		},
		properties = {
			floating = true,
			sticky = true,
			ontop = true,
			focus = true,
		},
		callback = resize,
	},
	{
		rule = { class = "firefox", role = "Dialog" },
		properties = { floating = true },
		callback = resize,
	},
	-- All LO windows have class "Soffice" when managed (the app re-classes
	-- the document frame to "libreoffice-writer" only after mapping), so
	-- split by window type: the app window opens filling the screen,
	-- in-app dialogs/menus keep floating + resized.
	{
		rule = { class = "Soffice", type = "normal" },
		properties = { floating = false, maximized = true },
	},
	{
		rule = { class = "Soffice" },
		except = { type = "normal" },
		properties = { floating = true },
		callback = resize,
	},
	{ rule = { class = "Xdg-desktop-portal-gtk" }, properties = { floating = true }, callback = resize },
	{ rule = { class = "tv" }, properties = { floating = true, focus = true }, callback = resize },
	-- Prewarmed menu terminal (menu.service). Kept hidden for the whole
	-- session: a hotkey shows it and scripts/menu hides it again once the
	-- command it runs is done. Sticky so it can be shown from any tag, above
	-- so it is not buried under other windows while a step is running.
	{
		rule = { class = "menu" },
		properties = {
			floating = true,
			sticky = true,
			above = true,
			skip_taskbar = true,
			hidden = true,
		},
		callback = resize,
	},
	-- Prewarmed input server (input.service): raw text prompts run in it.
	-- Same hidden-float lifecycle as the menu; it needs its own WM_CLASS
	-- because xremap hands menu/tv classes' word/line kills to tv, while
	-- input.input is excluded from every GUI rule and stays a terminal
	-- (tv/AGENTS.md, xremap/AGENTS.md).
	{
		rule = { class = "input" },
		properties = {
			floating = true,
			sticky = true,
			above = true,
			skip_taskbar = true,
			hidden = true,
		},
		callback = resize,
	},
	{ rule = { class = "Throne", name = "Confirmation" }, properties = { floating = true }, callback = resize },
	{ rule = { class = "Throne", name = "url detected" }, properties = { floating = true }, callback = resize },
	{ rule = { class = "Throne", name = "Edit" }, properties = { floating = true }, callback = resize },
	{ rule = { class = "Throne", name = "Dialog" }, properties = { floating = true }, callback = resize },
}
