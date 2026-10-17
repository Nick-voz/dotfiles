local awful = require("awful")
local gears = require("gears")

local menu = {}

menu.class = "menu"
menu.service = "menu.service"
menu.runtime_dir = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/awesome-menu"
menu.fifo = menu.runtime_dir .. "/request"

local pending -- request waiting for the window to come up
local busy = false
local mode = "auto"

local function find_client()
	for _, c in ipairs(client.get()) do
		if c.class == menu.class then
			return c
		end
	end
end

local function shell_quote(s)
	return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function hide(c)
	c = c or find_client()
	if c and not c.hidden then
		c.hidden = true
	end
end

local function activate(c)
	c:lower()
	c:emit_signal("request::activate", "menu", { raise = true })
end

local function send(cmd, request_mode)
	awful.spawn({
		"sh",
		"-c",
		string.format(
			"printf '%%s\\n%%s\\n' %s %s > %s",
			shell_quote(request_mode),
			shell_quote(cmd),
			shell_quote(menu.fifo)
		),
	}, false)
end

local function request_window(cmd, request_mode, action)
	pending = { cmd = cmd, mode = request_mode }
	awful.spawn({ "systemctl", "--user", action, "--no-block", menu.service }, false)
	local request = pending
	gears.timer.start_new(3, function()
		if pending == request then
			pending = nil
		end
	end)
end

function menu.open(cmd, request_mode)
	request_mode = request_mode or "auto"

	local c = find_client()

	if busy then
		if c and not c.hidden then
			return
		end

		request_window(cmd, request_mode, "restart")
		return
	end

	if not c then
		request_window(cmd, request_mode, "start")
		return
	end

	busy, mode = true, request_mode
	c.sticky = true
	if resize then
		resize(c) -- the screen may have changed while the window was hidden
	end
	c.hidden = false
	activate(c)
	gears.timer.start_new(0.05, function()
		if not c.hidden and client.focus == c then
			activate(c)
		end
	end)
	send(cmd, request_mode)
end

-- Called by the wrapper through awesome-client.
function menu.event(what, rc)
	if what == "busy" then
		busy = true
	elseif what == "done" then
		busy = false
		if mode ~= "hold" then
			hide()
		end
	end
end

client.connect_signal("unfocus", function(c)
	if c.class == menu.class then
		hide(c)
	end
end)

tag.connect_signal("property::selected", function()
	local c = find_client()
	if c then
		hide(c)
	end
end)

client.connect_signal("manage", function(c)
	if c.class ~= menu.class then
		return
	end

	-- Re-hide after an awesome restart (the rule does it on first spawn).
	c.sticky = true
	c.hidden = true

	if pending then
		gears.timer.start_new(0.1, function()
			local request = pending
			pending = nil
			if request then
				menu.open(request.cmd, request.mode)
			end
		end)
	end
end)

client.connect_signal("unmanage", function(c)
	if c.class == menu.class then
		busy = false
	end
end)

return menu
