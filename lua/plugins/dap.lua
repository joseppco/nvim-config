return {
    {
        "mfussenegger/nvim-dap",
        dependencies = {
            "williamboman/mason.nvim",
            "jay-babu/mason-nvim-dap.nvim",
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio",
        },
        keys = {
            { "<F5>",  function() require("dap").continue() end,          desc = "DAP: Continue" },
            { "<F10>", function() require("dap").step_over() end,         desc = "DAP: Step over" },
            { "<F11>", function() require("dap").step_into() end,         desc = "DAP: Step into" },
            { "<F12>", function() require("dap").step_out() end,          desc = "DAP: Step out" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle breakpoint" },
            { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "DAP: Conditional breakpoint" },
            { "<leader>dr", function() require("dap").repl.open() end,    desc = "DAP: Open REPL" },
            { "<leader>dl", function() require("dap").run_last() end,     desc = "DAP: Run last" },
            { "<leader>d[", function() require("dap").up() end,           desc = "DAP: Up frame" },
            { "<leader>d]", function() require("dap").down() end,         desc = "DAP: Down frame" },
            { "<leader>du", function() require("dapui").toggle() end,     desc = "DAP: Toggle UI" },
            { "<leader>dc", function()
                vim.ui.select(
                    vim.tbl_map(function(c) return c.name end, require("dap").configurations.cpp or {}),
                    { prompt = "Launch config: " },
                    function(name)
                        if not name then return end
                        for _, c in ipairs(require("dap").configurations.cpp or {}) do
                            if c.name == name then require("dap").run(c) return end
                        end
                    end
                )
            end, desc = "DAP: Choose config" },
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            -- codelldb adapter (installed by mason-nvim-dap below)
            local codelldb_path = vim.fn.stdpath("data")
                .. "/mason/packages/codelldb/extension/adapter/codelldb"
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = {
                    command = codelldb_path,
                    args = { "--port", "${port}" },
                },
            }

            local aimsun_next = vim.fn.expand("~/sources/aimsun-next")
            local qt_formatters = aimsun_next .. "/.vscode/debugger/macos/qt_lldb.py"
            local init_cmds = { "command script import " .. qt_formatters }

            dap.configurations.cpp = {
                {
                    name = "Aimsun Next (debug)",
                    type = "codelldb",
                    request = "launch",
                    program = aimsun_next .. "/build/debug/bin/Aimsun Next.app/Contents/MacOS/Aimsun Next",
                    args = { "-v", "--log", "--guru-db" },
                    cwd = aimsun_next,
                    stopOnEntry = false,
                    initCommands = init_cmds,
                    -- fix-mac.sh re-signs debug builds with com.apple.security.get-task-allow.
                },
                {
                    name = "Aimsun Next (debug-fast)",
                    type = "codelldb",
                    request = "launch",
                    program = aimsun_next .. "/build/debug-fast/bin/Aimsun Next.app/Contents/MacOS/Aimsun Next",
                    args = { "-v", "--log", "--guru-db" },
                    cwd = aimsun_next,
                    stopOnEntry = false,
                    initCommands = init_cmds,
                },
                {
                    name = "aconsole",
                    type = "codelldb",
                    request = "launch",
                    program = aimsun_next .. "/build/debug/bin/aconsole",
                    args = function()
                        local ang = vim.fn.input("Path to .ang file: ", "", "file")
                        local cmd = vim.fn.input("Command (e.g. ndet_files): ", "ndet_files")
                        local target = vim.fn.input("Scenario ID: ")
                        return { "--project", ang, "--command", cmd, "--target", target }
                    end,
                    cwd = aimsun_next,
                    stopOnEntry = false,
                    initCommands = init_cmds,
                },
                {
                    name = "Attach to process",
                    type = "codelldb",
                    request = "attach",
                    pid = function() return require("dap.utils").pick_process() end,
                    cwd = aimsun_next,
                    initCommands = init_cmds,
                },
            }

            -- c and cpp share the same configurations
            dap.configurations.c = dap.configurations.cpp

            -- Auto-open/close dapui
            dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
            dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
            dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

            dapui.setup()
        end,
    },
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
        opts = {
            ensure_installed = { "codelldb" },
            automatic_installation = true,
        },
    },
}
