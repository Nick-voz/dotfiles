-- Tabs are hidden (no tabline) and managed through the <leader>t keymaps
-- and the Snacks picker opened by <leader>ft. See nvim/AGENTS.md.
local M = {}

-- Tab recency, keyed by tabpage handle (buffer lastused is unreliable on
-- tab switches). TabEnter fires for new tabs too, so TabNew needs no hook.
local last_seen = {} ---@type table<number, number> handle -> microseconds
local hopping = false
local function touch()
  if hopping then
    return
  end
  local sec, usec = vim.uv.gettimeofday()
  last_seen[vim.api.nvim_get_current_tabpage()] = sec * 1e6 + usec
end
touch()
local group = vim.api.nvim_create_augroup("nik_tabs_recency", { clear = true })
vim.api.nvim_create_autocmd("TabEnter", { group = group, callback = touch, desc = "Track tab recency" })

-- Close a tab by its number (as shown by :tabs). There is no API to close a
-- background tab, so hop there, close, hop back; indices shift on success.
function M.close(tab)
  tab = tab or vim.fn.tabpagenr()
  if vim.fn.tabpagenr("$") == 1 then
    Snacks.notify.warn("Can't close the last tab")
    return
  end
  local cur = vim.fn.tabpagenr()
  local ok, err
  if tab == cur then
    ok, err = pcall(vim.cmd, "tabclose")
  else
    -- the hop is bookkeeping, not a visit: don't let it skew recency
    hopping = true
    vim.cmd("tabnext " .. tab)
    ok, err = pcall(vim.cmd, "tabclose")
    local back = (ok and cur > tab) and (cur - 1) or cur
    pcall(vim.cmd, "tabnext " .. math.min(back, vim.fn.tabpagenr("$")))
    hopping = false
    touch()
  end
  if not ok then
    Snacks.notify.error(err)
  end
end

function M.pick()
  Snacks.picker.pick({
    name = "tabs",
    title = "Tabs",
    layout = { preview = false },
    finder = function(_, ctx)
      local cur = vim.fn.tabpagenr()
      -- nvim_list_tabpages is ordered by tab number: index i = tab i
      local handles = vim.api.nvim_list_tabpages()
      local alive = {}
      for _, h in ipairs(handles) do
        alive[h] = true
      end
      for h in pairs(last_seen) do
        if not alive[h] then
          last_seen[h] = nil
        end
      end
      local items = {}
      -- gettabinfo gives real tab numbers (like :tabs); list_tabpages gives
      -- handles, which drift out of sync after closing tabs.
      -- The current tab is skipped (like recent files skip the current file),
      -- so the top entry is the previously visited tab: <leader>ft<cr> toggles back.
      for _, info in ipairs(vim.fn.gettabinfo()) do
        local tab = info.tabnr
        if tab ~= cur then
          local files = {}
          for _, win in ipairs(info.windows) do
            if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_config(win).relative == "" then
              local name = vim.fn.bufname(vim.api.nvim_win_get_buf(win))
              if name ~= "" then
                name = vim.fn.fnamemodify(name, ":~:.")
                if not vim.tbl_contains(files, name) then
                  table.insert(files, name)
                end
              end
            end
          end
          items[#items + 1] = {
            tab = tab,
            lastused = last_seen[handles[tab]] or 0,
            text = string.format("tab %d: %s", tab, table.concat(files, " | ")),
          }
        end
      end
      -- most recently entered tab first; stable order among unknown tabs
      table.sort(items, function(a, b)
        return a.lastused > b.lastused or (a.lastused == b.lastused and a.tab < b.tab)
      end)
      return ctx.filter:filter(items)
    end,
    format = function(item)
      return { { item.text } }
    end,
    actions = {
      confirm = function(picker, item)
        picker:close()
        if item then
          vim.schedule(function()
            vim.cmd("tabnext " .. item.tab)
          end)
        end
      end,
      tabclose = function(picker, item)
        if item then
          M.close(item.tab)
        end
        picker:refresh()
      end,
    },
    win = {
      input = {
        keys = {
          ["<c-x>"] = { "tabclose", mode = { "n", "i" }, desc = "Close Tab" },
        },
      },
      list = {
        keys = {
          ["w"] = { "tabclose", desc = "Close Tab" },
        },
      },
    },
  })
end

return M
