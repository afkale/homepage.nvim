-- Main module for the Homepage plugin
local M = {}

-- Load messages from the file at file_path
function M.load_homepage(file_path)
	-- Add plugin_dir to default path
	if file_path == M.opts.homepage_file then
		local plugin_dir = debug.getinfo(1, "S").source:match("@(.*/)") or "./"
		file_path = plugin_dir .. file_path
	end

	local file = io.open(file_path, "r")
	if not file then
		vim.notify("Failed to load homepage file: " .. file_path, vim.log.levels.ERROR)
		return
	end

	-- Clear existing homepage
	M.homepage = {}

	-- Read lines from the file and store them in the homepage table
	for line in file:lines() do
		table.insert(M.homepage, line)
	end

	file:close()
end

function M.print_homepage()
	-- Base padding
	local default_padding = math.floor(vim.o.columns / 2)

	-- Create a new buffer
	local buf = vim.api.nvim_create_buf(false, true)

	local aligned_homepage = {}
	for _, line in ipairs(M.homepage) do
		-- Calculate padding to center content
		local padding = default_padding - math.floor(vim.fn.strdisplaywidth(line) / 2)
		-- Create a separator with spaces to center content
		local sep = string.rep(" ", padding)
		-- Insert the content table
		table.insert(aligned_homepage, sep .. line)
	end

	-- Print the centered content into the buffer
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, aligned_homepage)

	-- Set the buffer to the current window
	vim.api.nvim_win_set_buf(0, buf)

	-- Apply the highlight
	for i = 0, #M.homepage - 1 do
		vim.api.nvim_buf_add_highlight(buf, -1, M.opts.highlight_name, i, 0, -1)
	end

	-- Clean buffer user custom settings
	M.clean_homepage(buf)
end

function M.clean_homepage(buf)
	-- Save old window settings
	local ows = {
		colorcolumn = vim.api.nvim_get_option_value("colorcolumn", { win = 0 }),
		cursorline = vim.api.nvim_get_option_value("cursorline", { win = 0 }),
		number = vim.api.nvim_get_option_value("number", { win = 0 }),
		relativenumber = vim.api.nvim_get_option_value("relativenumber", { win = 0 }),
	}

	-- Set buffer options
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	-- Delete user window settings
	vim.api.nvim_set_option_value("colorcolumn", "0", { win = 0 })
	vim.api.nvim_set_option_value("cursorline", false, { win = 0 })
	vim.api.nvim_set_option_value("number", false, { win = 0 })
	vim.api.nvim_set_option_value("relativenumber", false, { win = 0 })

	-- Restore the old window settings when leaving homepage buffer
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = buf,
		callback = function()
			vim.api.nvim_set_option_value("colorcolumn", ows.colorcolumn, { win = 0 })
			vim.api.nvim_set_option_value("cursorline", ows.cursorline, { win = 0 })
			vim.api.nvim_set_option_value("number", ows.number, { win = 0 })
			vim.api.nvim_set_option_value("relativenumber", ows.relativenumber, { win = 0 })
		end,
	})
end

function M.setup_highlight()
	-- Define a highlight group with the specified color
	vim.api.nvim_set_hl(0, M.opts.highlight_name, {
		fg = M.opts.color,
		bold = true,
	})
end

-- Table to store the homepage header
M.homepage = {}
-- Default homepage configurations
M.default_opts = {
	homepage_file = "../data/homepage",
	color = "#00ff00",
	highlight_name = "HomepageHighlight",
}

-- Set up the plugin
function M.setup(opts)
	-- Merge opts
	M.opts = vim.tbl_deep_extend("force", M.default_opts, opts or {})

	-- Setup the highlight color from hex color in opts
	M.setup_highlight()

	-- Load homepage
	M.load_homepage(M.opts.homepage_file)

	-- Autocmd to print the homepage on init
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			if vim.fn.argc() == 0 then
				M.print_homepage()
			end
		end,
		pattern = "*",
	})
end

-- Automatically setup
setmetatable(M, {
	__call = function(_, opts)
		M.setup(opts)
	end,
})

-- Return the module
return M
