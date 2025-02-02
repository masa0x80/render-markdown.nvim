local logger = require('render-markdown.logger')
local state = require('render-markdown.state')

local M = {}

---@param namespace number
---@param root TSNode
---@param buf integer
M.render = function(namespace, root, buf)
    local highlights = state.config.highlights
    for id, node in state.inline_query:iter_captures(root, buf) do
        local capture = state.inline_query.captures[id]
        local value = vim.treesitter.get_node_text(node, buf)
        local start_row, start_col, end_row, end_col = node:range()
        logger.debug_node(capture, node, buf)

        if capture == 'code' then
            vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                end_row = end_row,
                end_col = end_col,
                hl_group = highlights.code,
            })
        elseif capture == 'callout' then
            local value_to_key = {
                ['[!NOTE]'] = 'note',
                ['[!TIP]'] = 'tip',
                ['[!IMPORTANT]'] = 'important',
                ['[!WARNING]'] = 'warning',
                ['[!CAUTION]'] = 'caution',
            }
            local key = value_to_key[value]
            if key ~= nil then
                local virt_text = { state.config.callout[key], highlights.callout[key] }
                vim.api.nvim_buf_set_extmark(buf, namespace, start_row, start_col, {
                    end_row = end_row,
                    end_col = end_col,
                    virt_text = { virt_text },
                    virt_text_pos = 'overlay',
                })
            end
        else
            -- Should only get here if user provides custom capture, currently unhandled
            logger.error('Unhandled inline capture: ' .. capture)
        end
    end
end

return M
