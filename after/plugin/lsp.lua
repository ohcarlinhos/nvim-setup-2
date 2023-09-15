local lsp = require('lsp-zero')

lsp.preset('recommended')

-- Fix Undefined global 'vim'
lsp.nvim_workspace()

lsp.on_attach(function(_, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, { desc = "Go to definition" })
  vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, { desc = "Hover (Shows documentation)" })
  vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev() end, { desc = "Diagnostic: go to prev" })
  vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next() end, { desc = "Diagnostic: go to next" })
  vim.keymap.set('n', '<leader>cd', function() vim.diagnostic.open_float() end, { desc = "Open diagnostic" })
  vim.keymap.set('n', '<leader>ca', function() vim.lsp.buf.code_action() end, { desc = "Code Actions" })
  vim.keymap.set('n', '<leader>cf', function() vim.lsp.buf.references() end, { desc = "References" })
  vim.keymap.set('n', '<leader>cr', function() vim.lsp.buf.rename() end, { desc = "Rename" })
  vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, { desc = "Signature help" })
end)

-- CMP config

local cmp = require('cmp')
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp_action = require('lsp-zero').cmp_action()

local luasnip = require("luasnip")
local lspkind = require('lspkind')
local snippets = require('user.snippets')

local source_mapping = {
  buffer = "◉ Buffer",
  nvim_lsp = "👐 LSP",
  nvim_lua = "🌙 Lua",
  path = "🚧 Path",
  luasnip = "🌜 LuaSnip"
}

luasnip.config.set_config {
  history = true,
  ext_base_prio = 200,
  ext_prio_increase = 1,
  enable_autosnippets = false,
  store_selection_keys = "<c-s>",
}

luasnip.add_snippets(nil, snippets)

cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

cmp.setup({
  preselect = cmp.PreselectMode.None,
  -- completion = {
  --     completeopt = 'menu,menuone,noinsert'
  -- },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'nvim_lua' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
  },

  formatting = {
    format = function(entry, vim_item)
      vim_item.kind = lspkind.presets.default[vim_item.kind]
      local menu = source_mapping[entry.source.name]
      vim_item.menu = menu
      return vim_item
    end
  },
})

local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<CR>'] = cmp.mapping.confirm({ select = false }),
  ['<Tab>'] = cmp_action.luasnip_supertab(),
  ['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.set_sign_icons({
  error = '',
  warn = '',
  hint = '',
  info = ''
})

-- lspconfig

local lspconfig = require('lspconfig')
local lspconfig_configs = require('lspconfig.configs')
local lspconfig_util = require("lspconfig/util")

lspconfig.lua_ls.setup(lsp.nvim_lua_ls())

lspconfig.gopls.setup({
  cmd = { "gopls", "serve" },
  filetypes = { "go", "gomod" },
  root_dir = lspconfig_util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      staticcheck = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
        useany = true,
        unusedwrite = true,
        unusedvariable = true
      },
    },
  },

})

lspconfig.emmet_language_server.setup({
  filetypes = { 'html' }
})

lspconfig.volar.setup({
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' }
})

lsp.setup()

vim.diagnostic.config({
  virtual_text = true,
})

require("luasnip/loaders/from_vscode").load()
