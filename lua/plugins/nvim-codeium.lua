return {
 "Exafunction/codeium.nvim",
  event = 'BufEnter',
  dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },
    config = function()
       local g = vim.g
       g.codeium_auth_token="eyJhbGciOiJSUzI1NiIsImtpZCI6IjMzMDUxMThiZTBmNTZkYzA4NGE0NmExN2RiNzU1NjVkNzY4YmE2ZmUiLCJ0eXAiOiJKV1QifQ.eyJuYW1lIjoiVHJhbiBWYW4gVGFpIiwicGljdHVyZSI6Imh0dHBzOi8vbGgzLmdvb2dsZXVzZXJjb250ZW50LmNvbS9hL0FDZzhvY0xNZF9iMXBEZVNTRFVWSDA1Yl9QVlg4aXJoTGtuWk5rWWQ3aEhxRUxnPXM5Ni1jIiwiaXNzIjoiaHR0cHM6Ly9zZWN1cmV0b2tlbi5nb29nbGUuY29tL2V4YTItZmIxNzAiLCJhdWQiOiJleGEyLWZiMTcwIiwiYXV0aF90aW1lIjoxNzExMjczNDc1LCJ1c2VyX2lkIjoicElmenZRbUlwVFMxSFJsdXBLWGNNU1ExQk1ZMiIsInN1YiI6InBJZnp2UW1JcFRTMUhSbHVwS1hjTVNRMUJNWTIiLCJpYXQiOjE3MTc2NDQ4NzQsImV4cCI6MTcxNzY0ODQ3NCwiZW1haWwiOiJ0cmFudmFudGFpMDAxMUBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiZmlyZWJhc2UiOnsiaWRlbnRpdGllcyI6eyJnb29nbGUuY29tIjpbIjEwNzY5MDExODA5MjAxNTM5OTA3NiJdLCJlbWFpbCI6WyJ0cmFudmFudGFpMDAxMUBnbWFpbC5jb20iXX0sInNpZ25faW5fcHJvdmlkZXIiOiJnb29nbGUuY29tIn19.TG2_GAyLj_uxWbpA4bQFygOLDH-dY4WbBOONAHdYFgYtZFXZYn_7dR1FsrXWhLrgE0NPv6g3bTHCxRCFIfHyuXTmAOIstpozve5mDbKpkKJFFqU5stTIjHpmcxZU8YuzF75TI73QHlgZyGjVP8kSB4vy9I05lcG34zG4dpL7cr3LMq1PvHD9jLv6H8pF1evvux3kjO8SQnLlnXYcanC7u_M3eUMdv1N3WFLbrRdyWrB9QpUrFvpEEi3hUAf7kgS8vbQNqOIDGejN3-vccuDmON92yqSmveqtuqwQ9dh_aXnKXCa0lX8SHlqJol9lBBxkzHGenVFX5Pek3xxA4fqkXg"
       g.codeium_enabled = true
       g.codeium_render = true
       g.codeium_workspace_root_hints = {'.bzr','.git','.hg','.svn','_FOSSIL_','package.json','.sh'}
    end,
--    'github/copilot.vim',
}
