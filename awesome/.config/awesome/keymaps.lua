local awful = require("awful")
local gears = require("gears")
local wins = {
	["3"] = {
		[1] = "TelegramDesktop",
		[2] = "discord",
		[3] = "eu.betterbird.Betterbird",
		[4] = "zoom",
	},
	["6"] = {
		[1] = "obsidian",
		[2] = "Super Productivity",
	},
}

local function focus_specific_window(tag, i)
	local tag_name = tag.name
	if not wins[tag_name] then
		return
	end
	local cls = wins[tag_name][i]

	if not cls then
		return
	end

	local clients = client.get()
	for _, c in ipairs(clients) do
		if c.class == cls or c.class:lower() == cls:lower() then
			c:emit_signal("request::activate", "keyboard", { raise = true })
			c:jump_to()
			break
		end
	end
end

globalkeys = gears.table.join(
	awful.key({ MODKEY, SHIFT }, "b", function()
		for s in screen do
			s.mywibox.visible = not s.mywibox.visible
			if s.mybottomwibox then
				s.mybottomwibox.visible = not s.mybottomwibox.visible
			end
		end
	end, { description = "toggle wibox", group = "awesome" }),

	awful.key({ MODKEY }, "s", function()
		awful.spawn.with_shell("scrot")
	end, { description = "Make screenshot" }),
	awful.key({ MODKEY, SHIFT }, "s", function()
		awful.spawn.with_shell("scrot -s")
	end, { description = "Make selection screenshot" }),

	awful.key({ MODKEY }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ MODKEY }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),

	awful.key({ MODKEY, ALT }, "Left", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ MODKEY, ALT }, "Right", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),

	-- Layout manipulation
	awful.key({ MODKEY, ALT, SHIFT }, "Left", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ MODKEY, ALT, SHIFT }, "Right", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),

	-- Standard program
	awful.key({ MODKEY }, "Return", function()
		awful.spawn(TERMINAL)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ MODKEY, SHIFT }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ MODKEY, SHIFT }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	awful.key({ MODKEY }, "space", function()
		awful.spawn("menu")
	end),
	awful.key({ MODKEY }, "b", function()
		awful.spawn.with_shell("bookmarks")
	end),
	awful.key({ MODKEY }, "d", function()
		awful.spawn.with_shell("drun")
	end),
	awful.key({ MODKEY }, "p", function()
		awful.spawn.with_shell("power-menu")
	end),

	awful.key({ MODKEY, ALT }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ MODKEY, ALT, SHIFT }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ MODKEY, CONTROL, ALT, SHIFT }, "0", function()
		awful.spawn("setxkbmap us")
	end),
	awful.key({ MODKEY, CONTROL, ALT, SHIFT }, "1", function()
		awful.spawn('setxkbmap "ru(mac)"')
	end)
)

clientkeys = gears.table.join(
	awful.key({ MODKEY }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ MODKEY }, "q", function(c)
		c:kill()
	end, { description = "close", group = "client" })
)

clientbuttons = gears.table.join(
	awful.button({ MODKEY }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),

	awful.button({ MODKEY }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		awful.key({ MODKEY }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),

		awful.key({ MODKEY, SHIFT }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),

		awful.key({ MODKEY, ALT }, "#" .. i + 9, function()
			local tag = awful.screen.focused().selected_tag
			if tag then
				focus_specific_window(tag, i)
			end
		end, { description = "view client #" .. i, group = "tag" })
	)
end

root.keys(globalkeys)
