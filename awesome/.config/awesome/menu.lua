local awful = require("awful")
local gears = require("gears")

local menu = {}

-- Prewarmed server windows, keyed by WM_CLASS: "menu" (tv flows) and
-- "input" (raw text prompts; a class xremap treats as a plain terminal).
local window_names = { menu = true, input = true }

local state = {} -- per name: { busy, mode, pending }

local function st(name)
	local s = state[name]
	if not s then
		s = { name = name, busy = false, mode = "auto", pending = nil }
		state[name] = s
	end
	return s
end

local function find_client(name)
	for _, c in ipairs(client.get()) do
		if c.class == name then
			return c
		end
	end
end

local function shell_quote(s)
	return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function runtime_dir(name)
	return (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/awesome-" .. name
end

local function hide(s, c)
	c = c or find_client(s.name)
	if c and not c.hidden then
		c.hidden = true
	end
end

local function activate(c)
	c:lower()
	c:emit_signal("request::activate", "menu", { raise = true })
end

local function send(s, cmd, request_mode)
	awful.spawn({
		"sh",
		"-c",
		string.format(
			"printf '%%s\\n%%s\\n' %s %s > %s",
			shell_quote(request_mode),
			shell_quote(cmd),
			shell_quote(runtime_dir(s.name) .. "/request")
		),
	}, false)
end

local function request_window(s, cmd, request_mode, action)
	s.pending = { cmd = cmd, mode = request_mode }
	awful.spawn({ "systemctl", "--user", action, "--no-block", s.name .. ".service" }, false)
	local request = s.pending
	gears.timer.start_new(3, function()
		if s.pending == request then
			s.pending = nil
		end
	end)
end

function menu.open(cmd, request_mode, name)
	request_mode = request_mode or "auto"
	name = name or "menu"

	local s = st(name)
	s.name = name
	local c = find_client(name)

	if s.busy then
		if c and not c.hidden then
			return
		end

		request_window(s, cmd, request_mode, "restart")
		return
	end

	if not c then
		request_window(s, cmd, request_mode, "start")
		return
	end

	s.busy, s.mode = true, request_mode
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
	send(s, cmd, request_mode)
end

-- Called by the wrappers through awesome-client.
function menu.event(name, what, rc)
	local s = st(name)
	s.name = name
	if what == "busy" then
		s.busy = true
		-- an external `scripts/menu --send` (a helper finishing in another
		-- window) finds this one hidden: reopen it for the result
		local c = find_client(name)
		if c and c.hidden then
			if resize then
				resize(c)
			end
			c.hidden = false
			activate(c)
		end
	elseif what == "done" then
		s.busy = false
		if s.mode ~= "hold" then
			hide(s)
		end
	end
end

client.connect_signal("unfocus", function(c)
	if window_names[c.class] then
		hide(st(c.class), c)
	end
end)

tag.connect_signal("property::selected", function()
	for name in pairs(window_names) do
		hide(st(name))
	end
end)

client.connect_signal("manage", function(c)
	if not window_names[c.class] then
		return
	end

	-- Re-hide after an awesome restart (the rule does it on first spawn).
	c.sticky = true
	c.hidden = true

	local s = st(c.class)
	s.name = c.class
	if s.pending then
		gears.timer.start_new(0.1, function()
			local request = s.pending
			s.pending = nil
			if request then
				menu.open(request.cmd, request.mode, c.class)
			end
		end)
	end
end)

client.connect_signal("unmanage", function(c)
	local s = state[c.class]
	if window_names[c.class] and s then
		s.busy = false
	end
end)

return menu
