-- Main module for the Homepage plugin
local M = {}

-- Load messages from the file at file_path
function M.load_homepage()
	local file_path = M.opts.homepage_file

	-- Add dir path if file is inside of the library
	if M.default_opts.homepage_file == file_path then
		local plugin_dir = debug.getinfo(1, "S").source:match("@(.*/)") or "./"
		file_path = plugin_dir .. file_path
	end

	-- Load file from the file_path
	local file = io.open(file_path, "r")

	if not file then
		vim.notify("Failed to load homepage file: " .. M.opts.homepage_file, vim.log.levels.ERROR)
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
	vim.api.nvim_buf_set_lines(M.buf, 0, -1, false, aligned_homepage)

	-- Set the buffer to the current window
	vim.api.nvim_win_set_buf(0, M.buf)

	-- Apply the highlight
	for i = 0, #M.homepage - 1 do
		vim.api.nvim_buf_add_highlight(M.buf, -1, M.opts.highlight_name, i, 0, -1)
	end
end

function M.setup_homepage()
	-- Create a new buffer
	M.buf = vim.api.nvim_create_buf(false, true)

	-- Set the homepage title
	vim.api.nvim_buf_set_name(M.buf, M.opts.title)

	-- Print homepage in buffer
	M.print_homepage()

	-- Setup the highlight color from hex color in opts
	M.setup_highlight()

	-- Clean buffer user custom settings
	M.clean_homepage()
end

function M.clean_homepage()
	-- Save old window settings
	local ows = {
		colorcolumn = vim.api.nvim_get_option_value("colorcolumn", { win = 0 }),
		cursorline = vim.api.nvim_get_option_value("cursorline", { win = 0 }),
		number = vim.api.nvim_get_option_value("number", { win = 0 }),
		relativenumber = vim.api.nvim_get_option_value("relativenumber", { win = 0 }),
	}

	-- Set buffer options
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = M.buf })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = M.buf })
	vim.api.nvim_set_option_value("modifiable", false, { buf = M.buf })

	-- Delete user window settings
	vim.api.nvim_set_option_value("colorcolumn", "0", { win = 0 })
	vim.api.nvim_set_option_value("cursorline", false, { win = 0 })
	vim.api.nvim_set_option_value("number", false, { win = 0 })
	vim.api.nvim_set_option_value("relativenumber", false, { win = 0 })

	-- Restore the old window settings when leaving homepage buffer
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = M.buf,
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
	title = "homepage",
	color = "#00ff00",
	highlight_name = "HomepageHighlight",
}

-- Set up the plugin
function M.setup(opts)
	-- Merge opts
	M.opts = vim.tbl_deep_extend("force", M.default_opts, opts or {})

	-- Load homepage
	M.load_homepage()

	-- Autocmd to print the homepage on init
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			if vim.fn.argc() == 0 then
				M.setup_homepage()
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
