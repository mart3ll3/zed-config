vim.pack.add({
  { src = "https://github.com/stevearc/oil.nvim" },
})

local oil = require("oil")

local function select_in_zed()
  oil.select({
    handle_buffer_callback = function(bufnr)
      local path = vim.api.nvim_buf_get_name(bufnr)

      -- Oil represents directories as oil:// buffers.
      if vim.startswith(path, "oil://") then
        vim.cmd({
          cmd = "buffer",
          args = { bufnr },
        })
        return
      end

      local job = vim.fn.jobstart({ "zed", path }, {
        detach = true,
      })

      if job <= 0 then
        vim.notify("Could not open file in Zed: " .. path, vim.log.levels.ERROR)
        return
      end

      vim.cmd("qa!")
    end,
  })
end

oil.setup({
  default_file_explorer = true,
  columns = {},

  keymaps = {
    ["<CR>"] = {
      callback = select_in_zed,
      desc = "Open file in Zed",
    },
    ["<BS>"] = { "actions.parent", mode = "n" },

    ["<C-h>"] = false,
    ["<C-j>"] = false,
    ["<C-k>"] = false,
    ["<C-l>"] = false,
    ["<Space>e"] = {
      callback = function()
        vim.cmd("confirm qall")
      end,
      desc = "Close Oil",
      mode = "n",
    },
  },

  view_options = {
    show_hidden = true,
    is_always_hidden = function(name, _)
      return vim.tbl_contains({
        "dev-tools.locks",
        "dune.lock",
        "_build",
      }, name)
    end,
  },
})
