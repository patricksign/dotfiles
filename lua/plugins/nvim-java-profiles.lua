-- Java Profile Management Plugin
-- Allows saving and loading different environment configurations for debugging
return {
  'nvim-lua/plenary.nvim', -- For JSON handling and file operations
  config = function()
    local ProfileManager = {}
    
    -- Profile storage location
    local profile_dir = vim.fn.stdpath('data') .. '/java_profiles'
    local profile_file = profile_dir .. '/profiles.json'
    
    -- Ensure profile directory exists
    vim.fn.mkdir(profile_dir, 'p')
    
    -- Load profiles from file
    local function load_profiles()
      local file = io.open(profile_file, 'r')
      if file then
        local content = file:read('*all')
        file:close()
        local ok, profiles = pcall(vim.json.decode, content)
        if ok then
          return profiles or {}
        end
      end
      return {}
    end
    
    -- Save profiles to file
    local function save_profiles(profiles)
      local file = io.open(profile_file, 'w')
      if file then
        file:write(vim.json.encode(profiles))
        file:close()
      end
    end
    
    -- Create profile selection popup
    local function create_profile_popup(profiles, callback)
      local lines = {}
      local profile_names = {}
      
      table.insert(lines, "Java Debug Profiles")
      table.insert(lines, "==================")
      table.insert(lines, "")
      
      for i, profile in ipairs(profiles) do
        table.insert(lines, i .. ". " .. profile.name)
        table.insert(lines, "   Environment: " .. (profile.env_vars and table.concat(profile.env_vars, ", ") or "None"))
        table.insert(lines, "   VM Args: " .. (profile.vm_args or "Default"))
        table.insert(lines, "   Args: " .. (profile.args or "None"))
        table.insert(lines, "")
        profile_names[i] = profile.name
      end
      
      table.insert(lines, "0. Create New Profile")
      table.insert(lines, "q. Cancel")
      
      -- Create popup buffer
      local buf = vim.api.nvim_create_buf(false, true)
      local width = 60
      local height = #lines + 2
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)
      
      local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded'
      }
      
      local win = vim.api.nvim_open_win(buf, true, opts)
      
      -- Set buffer content
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(buf, 'modifiable', false)
      vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
      vim.api.nvim_buf_set_option(buf, 'filetype', 'java-profiles')
      
      -- Set keymaps
      local function close_popup()
        vim.api.nvim_win_close(win, true)
      end
      
      local function select_profile(index)
        if index == 0 then
          close_popup()
          ProfileManager.create_profile()
        elseif index > 0 and index <= #profiles then
          close_popup()
          callback(profiles[index])
        end
      end
      
      vim.keymap.set('n', 'q', close_popup, { buffer = buf, noremap = true })
      vim.keymap.set('n', '<CR>', function()
        local line = vim.api.nvim_win_get_cursor(win)[1]
        local profile_index = line - 4 -- Account for header
        if profile_index >= 0 and profile_index <= #profiles then
          select_profile(profile_index)
        elseif line == #lines - 1 then
          select_profile(0) -- Create new profile
        elseif line == #lines then
          close_popup()
        end
      end, { buffer = buf, noremap = true })
      
      vim.keymap.set('n', '<Esc>', close_popup, { buffer = buf, noremap = true })
      
      -- Highlight current line
      vim.api.nvim_create_autocmd('CursorMoved', {
        buffer = buf,
        callback = function()
          local line = vim.api.nvim_win_get_cursor(win)[1]
          vim.api.nvim_win_set_cursor(win, {line, 0})
        end
      })
    end
    
    -- Create new profile popup
    function ProfileManager.create_profile()
      local buf = vim.api.nvim_create_buf(false, true)
      local width = 80
      local height = 20
      local row = math.floor((vim.o.lines - height) / 2)
      local col = math.floor((vim.o.columns - width) / 2)
      
      local opts = {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded'
      }
      
      local win = vim.api.nvim_open_win(buf, true, opts)
      
      local lines = {
        "Create New Java Debug Profile",
        "=============================",
        "",
        "Profile Name: dev-local",
        "",
        "Environment Variables (one per line, format: KEY=value):",
        "SPRING_RABBITMQ_HOST=localhost",
        "SPRING_PROFILES_ACTIVE=dev",
        "SPRING_RABBITMQ_PASSWORD=p4ssw0rd",
        "SPRING_RABBITMQ_PORT=5672",
        "SPRING_RABBITMQ_USERNAME=rabbitmqroot",
        "STECH_COM_JPACONFIG_HOST=sb2-dev-rds-mysql-01.chx6brmqaryk.ap-east-1.rds.amazonaws.com",
        "JAVA_OPTS=-Xmx2G",
        "",
        "VM Arguments: -Xmx16G -Xms1G",
        "",
        "Program Arguments: --spring.profiles.active=common-dev",
        "",
        "Press <CR> to save, <Esc> to cancel"
      }
      
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.api.nvim_buf_set_option(buf, 'modifiable', true)
      vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
      
      -- Set cursor to profile name line
      vim.api.nvim_win_set_cursor(win, {4, 13})
      
      local function save_profile()
        local content = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        
        -- Extract profile name - find the line dynamically
        local name_line = nil
        local profile_name = nil
        
        -- Find the line containing "Profile Name:"
        for i, line in ipairs(content) do
          if line and line:match("Profile Name:") then
            name_line = line
            vim.notify("Found Profile Name line at index " .. i .. ": '" .. line .. "'", vim.log.levels.INFO)
            break
          end
        end
        
        if not name_line then
          vim.notify("Could not find 'Profile Name:' line in content", vim.log.levels.ERROR)
          return
        end
        
        -- Extract everything after "Profile Name:" and trim whitespace
        profile_name = name_line:gsub("Profile Name:", ""):gsub("^%s*(.-)%s*$", "%1")
        
        if not profile_name or profile_name == "" then
          vim.notify("Profile name is required. Line content: '" .. name_line .. "'", vim.log.levels.ERROR)
          return
        end
        
        vim.notify("Extracted profile name: '" .. profile_name .. "'", vim.log.levels.INFO)
        
        -- Extract environment variables - find them dynamically
        local env_vars = {}
        local in_env_section = false
        
        for i, line in ipairs(content) do
          if line and line:match("^Environment Variables") then
            in_env_section = true
            vim.notify("Found environment variables section at line " .. i, vim.log.levels.INFO)
          elseif in_env_section and (line:match("^VM Arguments") or line:match("^Program Arguments")) then
            in_env_section = false
            vim.notify("End of environment variables section at line " .. i, vim.log.levels.INFO)
          elseif in_env_section and line and line ~= "" then
            local key, value = line:match("^([^=]+)=(.+)")
            if key and value then
              -- Trim whitespace from key and value
              key = key:match("^%s*(.-)%s*$")
              value = value:match("^%s*(.-)%s*$")
              if key and value then
                table.insert(env_vars, key .. "=" .. value)
                vim.notify("Found env var: " .. key .. "=" .. value, vim.log.levels.INFO)
              end
            end
          end
        end
        
        -- Extract VM arguments - find dynamically
        local vm_args = nil
        for i, line in ipairs(content) do
          if line and line:match("^VM Arguments:") then
            vm_args = line:match("VM Arguments:%s*(.+)")
            vim.notify("Found VM args: '" .. (vm_args or "none") .. "'", vim.log.levels.INFO)
            break
          end
        end
        
        -- Extract program arguments - find dynamically
        local args = nil
        for i, line in ipairs(content) do
          if line and line:match("^Program Arguments:") then
            args = line:match("Program Arguments:%s*(.+)")
            vim.notify("Found program args: '" .. (args or "none") .. "'", vim.log.levels.INFO)
            break
          end
        end
        
        -- Create profile
        local profile = {
          name = profile_name,
          env_vars = env_vars,
          vm_args = vm_args ~= "" and vm_args or nil,
          args = args ~= "" and args or nil
        }
        
        -- Debug output
        vim.notify("Profile parsed: '" .. profile_name .. "' with " .. #env_vars .. " env vars", vim.log.levels.INFO)
        if #env_vars > 0 then
          vim.notify("First env var: " .. env_vars[1], vim.log.levels.INFO)
        end
        
        -- Save to profiles
        local profiles = load_profiles()
        table.insert(profiles, profile)
        save_profiles(profiles)
        
        vim.api.nvim_win_close(win, true)
        vim.notify("Profile '" .. profile_name .. "' saved successfully", vim.log.levels.INFO)
        
        -- Auto-run the new profile
        ProfileManager.run_with_profile(profile)
      end
      
      vim.keymap.set('n', '<CR>', save_profile, { buffer = buf, noremap = true })
      vim.keymap.set('n', '<Esc>', function() vim.api.nvim_win_close(win, true) end, { buffer = buf, noremap = true })
    end
    
    -- Run Java application with profile
    function ProfileManager.run_with_profile(profile)
      local dap_ok, dap = pcall(require, 'dap')
      if not dap_ok then
        vim.notify("DAP not available", vim.log.levels.ERROR)
        return
      end
      
      -- Get current Java file info
      local main_class = vim.fn.expand('%:t:r')
      local package_line = vim.fn.search('^package', 'n')
      if package_line > 0 then
        local package_name = vim.fn.getline(package_line):match('package%s+([%w%.]+)')
        if package_name then
          main_class = package_name .. '.' .. main_class
        end
      end
      
      -- Build environment variables string
      local env_vars_str = ""
      if profile.env_vars and #profile.env_vars > 0 then
        env_vars_str = table.concat(profile.env_vars, " ")
      end
      
      -- Create debug configuration
      local config = {
        type = 'java',
        request = 'launch',
        name = 'Debug with Profile: ' .. profile.name,
        mainClass = main_class,
        projectName = vim.fn.fnamemodify(vim.fn.getcwd(), ":t"),
        cwd = '${workspaceFolder}',
        stopOnEntry = false,
        args = profile.args or '',
        vmArgs = profile.vm_args or '-Xmx2G',
        env = {}
      }
      
      -- Add environment variables
      if profile.env_vars then
        for _, env_var in ipairs(profile.env_vars) do
          local key, value = env_var:match("^([^=]+)=(.+)")
          if key and value then
            config.env[key] = value
          end
        end
      end
      
      -- Run the configuration
      dap.run(config)
      
      vim.notify("Starting debug session with profile: " .. profile.name, vim.log.levels.INFO)
    end
    
    -- Show profile selection popup
    function ProfileManager.show_profiles()
      local profiles = load_profiles()
      create_profile_popup(profiles, function(profile)
        ProfileManager.run_with_profile(profile)
      end)
    end
    
    -- Edit existing profile
    function ProfileManager.edit_profile(profile_name)
      local profiles = load_profiles()
      local profile_index = nil
      
      for i, profile in ipairs(profiles) do
        if profile.name == profile_name then
          profile_index = i
          break
        end
      end
      
      if not profile_index then
        vim.notify("Profile not found: " .. profile_name, vim.log.levels.ERROR)
        return
      end
      
      -- TODO: Implement profile editing
      vim.notify("Profile editing not yet implemented", vim.log.levels.WARN)
    end
    
    -- Delete profile
    function ProfileManager.delete_profile(profile_name)
      local profiles = load_profiles()
      local new_profiles = {}
      
      for _, profile in ipairs(profiles) do
        if profile.name ~= profile_name then
          table.insert(new_profiles, profile)
        end
      end
      
      save_profiles(new_profiles)
      vim.notify("Profile deleted: " .. profile_name, vim.log.levels.INFO)
    end
    
    -- List all profiles
    function ProfileManager.list_profiles()
      local profiles = load_profiles()
      if #profiles == 0 then
        vim.notify("No profiles saved. Use :JavaProfileCreate to create one.", vim.log.levels.INFO)
        return
      end
      
      print("Java Debug Profiles:")
      print("===================")
      for i, profile in ipairs(profiles) do
        print(i .. ". " .. profile.name)
        if profile.env_vars and #profile.env_vars > 0 then
          print("   Environment: " .. table.concat(profile.env_vars, ", "))
        end
        if profile.vm_args then
          print("   VM Args: " .. profile.vm_args)
        end
        if profile.args then
          print("   Args: " .. profile.args)
        end
        print()
      end
    end
    
    -- Create user commands
    vim.api.nvim_create_user_command('JavaProfileShow', function()
      ProfileManager.show_profiles()
    end, { desc = 'Show Java debug profiles' })
    
    vim.api.nvim_create_user_command('JavaProfileCreate', function()
      ProfileManager.create_profile()
    end, { desc = 'Create new Java debug profile' })
    
    vim.api.nvim_create_user_command('JavaProfileList', function()
      ProfileManager.list_profiles()
    end, { desc = 'List all Java debug profiles' })
    
    vim.api.nvim_create_user_command('JavaProfileDelete', function(opts)
      ProfileManager.delete_profile(opts.args)
    end, { desc = 'Delete Java debug profile', nargs = 1 })
    
    vim.api.nvim_create_user_command('JavaProfileTest', function()
      -- Test profile creation with sample data
      local test_profile = {
        name = "test-profile",
        env_vars = {
          "SPRING_RABBITMQ_HOST=localhost",
          "SPRING_PROFILES_ACTIVE=test",
          "JAVA_OPTS=-Xmx1G"
        },
        vm_args = "-Xmx1G -Xms512M",
        args = "--spring.profiles.active=test"
      }
      
      local profiles = load_profiles()
      table.insert(profiles, test_profile)
      save_profiles(profiles)
      
      vim.notify("Test profile created successfully", vim.log.levels.INFO)
      ProfileManager.list_profiles()
    end, { desc = 'Test Java profile creation' })
    
    -- Commands are now defined in core/startup_messages.lua
    
    -- Add keymaps
    local remap = function(mode, lhs, rhs, opts)
      local options = { noremap = true, silent = true }
      if opts then
        options = vim.tbl_extend("force", options, opts)
      end
      vim.keymap.set(mode, lhs, rhs, options)
    end
    
    -- Global keymaps for profile management
    remap('n', '<leader>jp', function() ProfileManager.show_profiles() end, 
          { desc = "Java: Show Debug Profiles" })
    remap('n', '<leader>jc', function() ProfileManager.create_profile() end, 
          { desc = "Java: Create Debug Profile" })
    
    -- Java filetype specific keymaps
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'java',
      callback = function()
        local bufopts = { buffer = true }
        remap('n', '<leader>jp', function() ProfileManager.show_profiles() end, bufopts, "Java: Show Debug Profiles")
        remap('n', '<leader>jc', function() ProfileManager.create_profile() end, bufopts, "Java: Create Debug Profile")
      end
    })
    
    -- Show startup message using the new startup message system
    vim.defer_fn(function()
        local startup_messages = require('core.startup_messages')
        startup_messages.show_startup_info()
    end, 1500)
  end,
  event = 'VeryLazy',
} 