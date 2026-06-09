-- Async build via the `an-build` zsh function, results into the quickfix list.
-- `zsh -ic` runs an interactive shell so the function defined in ~/.zshrc is available.

local M = {}

local job_id = nil
local full_items = {} -- last build's complete parsed list (errors + warnings + notes)
local title = "an-build"
M.filter_mode = "errors" -- "errors" | "all"

local function is_error(item)
    return item.valid == 1 and vim.fn.tolower(item.type) == "e"
end

-- Repopulate the quickfix list from the last build according to M.filter_mode.
local function apply()
    local items = full_items
    if M.filter_mode == "errors" then
        items = vim.tbl_filter(is_error, full_items)
    end
    vim.fn.setqflist({}, " ", {
        title = title .. " [" .. M.filter_mode .. "]",
        items = items,
    })
end

function M.toggle()
    M.filter_mode = (M.filter_mode == "errors") and "all" or "errors"
    apply()
    vim.cmd("copen")
    vim.notify("quickfix: " .. M.filter_mode)
end

function M.build(preset)
    preset = preset or "debug"

    if job_id then
        vim.notify("an-build already running", vim.log.levels.WARN)
        return
    end

    local lines = {}
    vim.notify("an-build " .. preset .. " …")

    job_id = vim.fn.jobstart({ "zsh", "-ic", "an-build " .. preset }, {
        -- Clang errors arrive on stderr; capture both streams.
        stdout_buffered = true,
        stderr_buffered = true,
        on_stdout = function(_, d) vim.list_extend(lines, d) end,
        on_stderr = function(_, d) vim.list_extend(lines, d) end,
        on_exit = function(_, code)
            job_id = nil
            title = "an-build " .. preset
            -- Parse once into a temporary list, then keep the items around so we
            -- can re-filter between errors-only and all without rebuilding.
            vim.fn.setqflist({}, " ", {
                lines = lines,
                -- standard gcc/clang error format
                efm = "%f:%l:%c: %t%*[^:]: %m,%f:%l:%c: %m",
            })
            full_items = vim.fn.getqflist()
            apply()

            local errs = vim.tbl_filter(is_error, full_items)
            local warns = #vim.tbl_filter(function(e) return e.valid == 1 and vim.fn.tolower(e.type) == "w" end, full_items)
            if #errs > 0 then
                vim.cmd("copen")
                vim.cmd("cfirst") -- jump to the first error automatically
                vim.notify(("an-build failed: %d errors, %d warnings"):format(#errs, warns), vim.log.levels.ERROR)
            else
                vim.cmd("cclose")
                vim.notify(
                    code == 0 and ("an-build OK (%d warnings)"):format(warns) or ("an-build exited " .. code),
                    code == 0 and vim.log.levels.INFO or vim.log.levels.WARN
                )
            end
        end,
    })

    if job_id <= 0 then
        job_id = nil
        vim.notify("Failed to start an-build", vim.log.levels.ERROR)
    end
end

function M.stop()
    if job_id then
        vim.fn.jobstop(job_id)
        job_id = nil
        vim.notify("an-build stopped", vim.log.levels.WARN)
    end
end

vim.api.nvim_create_user_command("AnBuild", function(o)
    M.build(o.args ~= "" and o.args or nil)
end, { nargs = "?", desc = "Async an-build into quickfix" })

vim.api.nvim_create_user_command("AnBuildStop", M.stop, { desc = "Stop running an-build" })
vim.api.nvim_create_user_command("AnQfToggle", M.toggle, { desc = "Toggle quickfix errors-only / all" })

local map = vim.keymap.set
map("n", "<leader>b", "<cmd>AnBuild debug<CR>", { desc = "an-build debug" })
map("n", "<leader>B", "<cmd>AnBuild release<CR>", { desc = "an-build release" })
map("n", "<leader>q", "<cmd>copen<CR>", { desc = "Open quickfix" })
map("n", "<leader>w", "<cmd>AnQfToggle<CR>", { desc = "Toggle qf errors/all" })
-- ]q / [q (next/prev quickfix) are defined in keymaps.lua

return M
