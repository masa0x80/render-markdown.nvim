# markdown.nvim

Plugin to improve viewing Markdown files in Neovim

![Demo](demo/demo.gif)

# Features

- Functions entirely inside of Neovim with no external windows
- Changes between `rendered` view in normal mode and `raw` view in all other modes
- Changes `conceallevel` between `rendered` and `raw` view based on configuration
- Supports rendering `markdown` injected into other file types
- Highlights headings with different groups depending on level and replaces `#`
- Updates horizontal breaks with full-width lines
- Highlights code blocks and inline code to better stand out
- Replaces bullet points with provided character based on level
- Replaces checkboxes with provided characters based on whether they are checked
- Replaces block quote leading `>` with provided character
- Updates table borders with better border characters, does NOT automatically align
- Basic support for `LaTeX` if `pylatexenc` is installed on system
- Disable rendering when file is larger than provided value
- Support for [callouts](https://github.com/orgs/community/discussions/16925)

# Dependencies

- [markdown & markdown_inline](https://github.com/tree-sitter-grammars/tree-sitter-markdown)
  parsers for [treesitter](https://github.com/nvim-treesitter/nvim-treesitter):
  Used to parse `markdown` files
- [pylatexenc](https://pypi.org/project/pylatexenc/) (Optional): Used to
  transform `LaTeX` strings to appropriate unicode using `latex2text`

# Install

## lazy.nvim

```lua
{
    'MeanderingProgrammer/markdown.nvim',
    name = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
        require('render-markdown').setup({})
    end,
}
```

## packer.nvim

```lua
use({
    'MeanderingProgrammer/markdown.nvim',
    as = 'render-markdown', -- Only needed if you have another plugin named markdown.nvim
    after = { 'nvim-treesitter' },
    config = function()
        require('render-markdown').setup({})
    end,
})
```

# Setup

Below is the configuration that gets used by default, any part of it can be modified
by the user.

```lua
require('render-markdown').setup({
    -- Configure whether Markdown should be rendered by default or not
    start_enabled = true,
    -- Maximum file size (in MB) that this plugin will attempt to render
    -- Any file larger than this will effectively be ignored
    max_file_size = 1.5,
    -- Capture groups that get pulled from markdown
    markdown_query = [[
        (atx_heading [
            (atx_h1_marker)
            (atx_h2_marker)
            (atx_h3_marker)
            (atx_h4_marker)
            (atx_h5_marker)
            (atx_h6_marker)
        ] @heading)

        (thematic_break) @dash

        (fenced_code_block) @code

        [
            (list_marker_plus)
            (list_marker_minus)
            (list_marker_star)
        ] @list_marker

        (task_list_marker_unchecked) @checkbox_unchecked
        (task_list_marker_checked) @checkbox_checked

        (block_quote (block_quote_marker) @quote_marker)
        (block_quote (paragraph (inline (block_continuation) @quote_marker)))

        (pipe_table) @table
        (pipe_table_header) @table_head
        (pipe_table_delimiter_row) @table_delim
        (pipe_table_row) @table_row
    ]],
    -- Capture groups that get pulled from inline markdown
    inline_query = [[
        (code_span) @code

        (shortcut_link) @callout
    ]],
    -- The level of logs to write to file: vim.fn.stdpath('state') .. '/render-markdown.log'
    -- Only intended to be used for plugin development / debugging
    log_level = 'error',
    -- Filetypes this plugin will run on
    file_types = { 'markdown' },
    -- Vim modes that will show a rendered view of the markdown file
    -- All other modes will be uneffected by this plugin
    render_modes = { 'n', 'c' },
    -- Characters that will replace the # at the start of headings
    headings = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
    -- Character to use for the horizontal break
    dash = '—',
    -- Character to use for the bullet points in lists
    bullets = { '●', '○', '◆', '◇' },
    checkbox = {
        -- Character that will replace the [ ] in unchecked checkboxes
        unchecked = '󰄱 ',
        -- Character that will replace the [x] in checked checkboxes
        checked = ' ',
    },
    -- Character that will replace the > at the start of block quotes
    quote = '┃',
    -- Symbol / text to use for different callouts
    callout = {
        note = '  Note',
        tip = '  Tip',
        important = '󰅾  Important',
        warning = '  Warning',
        caution = '󰳦  Caution',
    },
    -- See :h 'conceallevel' for more information about meaning of values
    conceal = {
        -- conceallevel used for buffer when not being rendered, get user setting
        default = vim.opt.conceallevel:get(),
        -- conceallevel used for buffer when being rendered
        rendered = 3,
    },
    -- Determines how tables are rendered
    --  full: adds a line above and below tables + normal behavior
    --  normal: renders the rows of tables
    --  none: disables rendering, use this if you prefer having cell highlights
    table_style = 'full',
    -- Define the highlight groups to use when rendering various components
    highlights = {
        heading = {
            -- Background of heading line
            backgrounds = { 'DiffAdd', 'DiffChange', 'DiffDelete' },
            -- Foreground of heading character only
            foregrounds = {
                'markdownH1',
                'markdownH2',
                'markdownH3',
                'markdownH4',
                'markdownH5',
                'markdownH6',
            },
        },
        -- Horizontal break
        dash = 'LineNr',
        -- Code blocks
        code = 'ColorColumn',
        -- Bullet points in list
        bullet = 'Normal',
        checkbox = {
            -- Unchecked checkboxes
            unchecked = '@markup.list.unchecked',
            -- Checked checkboxes
            checked = '@markup.heading',
        },
        table = {
            -- Header of a markdown table
            head = '@markup.heading',
            -- Non header rows in a markdown table
            row = 'Normal',
        },
        -- LaTeX blocks
        latex = '@markup.math',
        -- Quote character in a block quote
        quote = '@markup.quote',
        -- Highlights to use for different callouts
        callout = {
            note = 'DiagnosticInfo',
            tip = 'DiagnosticOk',
            important = 'DiagnosticHint',
            warning = 'DiagnosticWarn',
            caution = 'DiagnosticError',
        },
    },
})
```

# Commands

`:RenderMarkdownToggle` - Switch between enabling & disabling this plugin

- Function can also be accessed directly through `require('render-markdown').toggle()`

# Purpose

There are many existing markdown rendering plugins in the Neovim ecosystem. However,
most of these rely on syncing a separate browser window with the buffer. This is
the correct way to do things to get full feature support, however I wanted something
that worked completely inside of Neovim and made things look slightly "nicer".

The closest one I found to this was [headlines.nvim](https://github.com/lukas-reineke/headlines.nvim),
which is an awesome plugin that I took several ideas from. However it just didn't
have quite what I was looking for. In particular I wanted something that would
disappear completely when editing a file and quickly render some style when viewing
the file. Hence this plugin.

# Markdown Ecosystem

There are many `markdown` plugins that specialize in different aspects of interacting
with `markdown` files. This plugin specializes in rendering the buffer inside of
Neovim, for instance. As a result some plugins will clash with this one, whereas
other plugins handle orthogonal concerns and can be used in addition to this one.
Below is a categorized (incomplete) list of available plugins.

## Render in Neovim

Using any of these plugins with this one will likely lead to undesired behavior as
different functionality will clash.

- [headlines.nvim](https://github.com/lukas-reineke/headlines.nvim) - Same high
  level idea and starting point of this plugin, but with different feature sets

## Render in Browser

These can be used as a second pass to get a real preview of the `markdown` file.
Since they do not interact with the buffer directly there should be no issues.

- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)
- [vim-markdown-composer](https://github.com/euclio/vim-markdown-composer)

## Orthogonal

These plugins handle functions completely separate from rendering and should also
have no issues running alongside this plugin.

- Any LSP which provides standard LSP capabilities, such as:
  - [marksman](https://github.com/artempyanykh/marksman) - General completion,
    definition, and reference functionality
  - [markdown-oxide](https://github.com/Feel-ix-343/markdown-oxide) - Adds Obsidian
    PKM features to LSP
- [markdown.nvim](https://github.com/tadmccorkle/markdown.nvim) - Adds `markdown`
  specific keybindings for interacting with `markdown` files
