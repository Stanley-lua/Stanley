return {
    name = 'stanley',

    --[[ Config file handling ]]
    config_schema = {'name','description','version','author','autoload','require'},
    config_file_name = 'package.yaml',
    config = {},

    -- Load configuration and build queue
    initialize = function(self)
        if File.exists(self.config_file_name) then
            -- Parse configuration file 'package.yaml'
            self.config = YAML.parse(
                File.get_lines(self.config_file_name)
            )
            self.autoload_template = self.autoload_template:gsub('__NAME__', self.name)

            -- Build queue according to configuration
            self.autoload = {}
            self.packages = {}
            self:buildQueue(self.config)
        end
    end,

    -- Dump self.config to package.yaml
    save = function(self)
        local file = File.open(self.config_file_name, 'w')
        file:write(YAML.dump(self.config, self.config_schema))
        File.close(file)
        io.write('\nCurrent configuration has been saved to \'package.yaml\' file.\n')
    end,

    -- Required list manipulation
    hasRequired = function(self, repo)
        if self.config.require then
            local package = {
                name = repo,
                source = CLI:getOption('source')
            }
            for index, required in ipairs(self.config.require) do
                local source = required.source or CLI:getDefault('source')
                if package.name == required.name and package.source == source then
                    return true, index
                end
            end
        end
        return false, nil
    end,

    requirePackages = function(self, ...)
        local repos = { ... }
        if not self.config.require then
            self.config.require = {}
        end
        local changed = false
        local source = CLI:getOption('source')
        for _,repo in ipairs(repos) do
            local package_text = 'Package "' .. source .. repo .. '" '
            if not self:hasRequired(repo) then
                local package = { name = repo }
                if source ~= CLI:getDefault('source') then
                    package.source = source
                end
                table.insert(self.config.require, package)
                changed = true
                io.write(package_text .. 'added to required list.\n')
            else
                io.write(package_text .. 'is already required. Skip.\n')
            end
        end
        if changed then
            self:save()
        end
    end,

    removePackages = function(self, ...)
        if not self.config.require then return end
        local repos = { ... }
        local changed = false
        local source = CLI:getOption('source')
        for _,repo in ipairs(repos) do
            local package_text = 'Package "' .. source .. repo .. '" '
            local has, index = self:hasRequired(repo)
            if has then
                table.remove(self.config.require, index)
                changed = true
                io.write(package_text .. 'has been removed from list.\n')
            else
                io.write(package_text .. 'not found. Skip.\n')
            end
        end
        if changed then
            self:save()
        end
    end,

    initializePackage = function(self)
        io.write('\nInitializing "' .. self.config_file_name .. '" file...\n\n')
        io.write('Please provide information for the package:\n')
        self.config.name = CLI:input('Name:', self.config.name)
        self.config.description = CLI:input('Description:', self.config.description)
        self.config.version = CLI:input('Version:', self.config.version or '0.1')
        local answer = false
        
        answer = CLI:confirm('Do you want to add author information?', false)
        if answer == true then
            if CLI:confirm('Overwrite previous information?', false) == true then
                self.config.author = {}
            else
                self.config.author = self.config.author or {}
            end
            while answer == true do
                local author = {}
                while author.name == nil do
                    author.name = CLI:input('Author name:')
                end
                while author.email == nil do
                    author.email = CLI:input('Author email:')
                end
                table.insert(self.config.author, author)
                answer = CLI:confirm('Add another?', false)
            end
        end
        
        answer = CLI:confirm('Do you want to add autoload information?', false)
        if answer == true then
            if CLI:confirm('Overwrite previous information?', false) == true then
                self.config.autoload = {}
            else
                self.config.autoload = self.config.autoload or {}
            end
            while answer == true do
                local autoload = {}
                autoload.type = CLI:choice('Autoload type:', {'file', 'global'})
                if autoload.type == 'global' then
                    while autoload.name == nil do
                        autoload.name = CLI:input('Autoload global:')
                    end
                end
                autoload.path = CLI:input('Autoload path:', 'init.lua')
                autoload.relative = CLI:input('Is this path relative to current package?', true)
                table.insert(self.config.autoload, autoload)
                answer = CLI:confirm('Add another?', false)
            end
        end

        answer = CLI:confirm('Do you want to add some packages to require list?', false)
        if answer == true then
            if CLI:confirm('Overwrite previous information?', false) == true then
                self.config.require = {}
            else
                self.config.require = self.config.require or {}
            end
            while answer == true do
                local package = {}
                while package.name == nil do
                    package.name = CLI:input('Package name:')
                end
                package.source = CLI:input('Package source:', CLI:getOption('source'))
                if package.source == CLI:getOption('source') then
                    package.source = nil
                end
                table.insert(self.config.require, package)
                answer = CLI:confirm('Add another?', false)
            end
        end

        self:save()
    end,

    updatePackages = function(self)
        os.execute('mkdir -p ./lib') -- ensure lib directory exists
        local git = os.capture('which git')
        io.write('\nUpdating packages from sources...\n')
        for _,queued in ipairs(self.packages) do
            if queued.source ~= 'local' then
                local source = queued.source or self.config.default_source or CLI:getOption('source')
                source = source .. queued.name
                io.write('\nDownloading from: ' .. source .. '\n')
                io.flush()
                local target = './lib/' .. (queued.target or queued.name)
                if not File.exists(target .. '/') then
                    os.execute(git .. ' clone ' .. source .. ' ' .. target)
                else
                    os.execute('cd ' .. target .. ' && ' .. git .. ' pull')
                end
                os.execute('sleep 2')
            end
        end
        io.write('\nDone.\n')
    end,
    --[[ Config file handling ]]

    --[[ Queue handling ]]
    --[[ Loaded packages structure:
        {
            name = 'test/package',
            target = 'test/package2/gitea',
            source = 'https://gitea.org/'
        },
        {
            name = 'test/ssh_package',
            source = 'ssh://git@github.com:'
        },
        {
            name = 'test/package2',
            source = 'local'
        }
    --]]
    packages = {},

    hasQueued = function(self, package)
        if type(package) == 'string' then
            local name = package
            package = {
                name = name,
                source = CLI:getOption('source'),
                target = CLI:getOption('target')
            }
        end
        for index, queued in ipairs(self.packages) do
            local source = queued.source or CLI:getOption('source')
            if package.name == queued.name and package.source == source then
                return true, index
            end
        end
        return false, nil
    end,

    queuePackage = function(self, package)
        if self:hasQueued(package) then return end

        debug(4, 'Required package', package)
        if package.name then
            local package_config_path = 'lib/' .. package.name .. '/' .. self.config_file_name
            debug(5, 'Required package config path', package_config_path)

            local package_config = File.get_lines(package_config_path)
            if package_config then
                package_config = YAML.parse(package_config)
                self:buildQueue(package_config)
            end

            -- Set package as processed
            table.insert(self.packages, package)
        end
    end,
    
    buildQueue = function(self, config)
        debug(4, 'Build queue from config', config)

        if config.require then
            for _,required in ipairs(config.require) do
                self:queuePackage(required)
            end
        end

        if config.autoload then
            for _,item in ipairs(config.autoload) do
                self:addToAutoload(item, config)
            end
        elseif File.exists('./lib/' .. config.name .. '/init.lua') then
            self:addToAutoload({
                type = 'file',
                path = 'init.lua'
            }, config)
        end

        debug(5, 'Processed packages', self.packages)
        debug(5, 'Processed autoload', self.autoload)  
    end,
    --[[ Queue handling ]]

    --[[ Autoload structure:
        {
            type = 'file',
            path = 'init.lua',
            relative = true
        },
        {
            type = 'global',
            path = 'test.lua'
            name = 'test',
        }
    --]]
    autoload = {},
    autoload_template = "package.path = package.path .. ';./?/init.lua;~/.__NAME__/libs/?.lua;~/.__NAME__/libs/?/init.lua'\npackage.path = package.path .. ';' .. package.path:gsub('%.lua', '.luac')\ntable.insert(package.loaders, 2, function(modulename)\n\tlocal errmsg, modulepath = '', modulename:gsub('%.', '/'):gsub('`/', '.')\n\tfor path in package.path:gmatch('([^;]+)') do\n\t\tlocal filename = path:gsub('%?', modulepath)\n\t\tlocal file = io.open(filename, 'rb')\n\t\tif file then return assert(loadstring(assert(file:read('*a')), filename)) end\n\t\terrmsg = errmsg..'\\n\\tno file \\''..filename..'\\''\n\tend return errmsg\nend)\n",

    _compareAndValidateItems = function(item1, item2)
        if item1.type ~= item2.type and item1.path ~= item2.path then
            return false
        end
        if item1.relative == item2.relative then
            if item1.type == 'global' then
                return item1.name ~= nil and item2.name ~= nil and item1.name == item2.name
            end
            return true
        end
        return false
    end,

    hasInAutoload = function(self, item)
        for _,queued in ipairs(self.autoload) do
            if self._compareAndValidateItems(item, queued) then
                return true
            end
        end
        return false
    end,

    addToAutoload = function(self, item, package)
        item.path = item.path:gsub('%.luac?$', '')
        if item.relative ~= false then
            item.path = package.name .. '/' .. item.path
        end
        item.path = 'lib.' .. item.path:gsub('%.', '`.'):gsub('/', '.')
        if self:hasInAutoload(item) then return end
        debug(5, 'Adding to autoload', item)
        table.insert(self.autoload, item)
    end,

    generateAutoloadFile = function(self)
        os.execute('mkdir -p ./lib') -- ensure lib directory exists
        local file = File.open('lib/autoload.lua', 'w')
        file:write('-- This file was generated by ' .. self.name:sub(1,1):upper() .. self.name:sub(2) .. ' :)\n')
        file:write(self.autoload_template .. '\n')
        local local_path = 'lib.' .. self.config.name:gsub('%.', '`.'):gsub('/', '.') .. '.'
        for _,queued in ipairs(self.autoload) do
            debug(2, 'Queued item', queued)
            if queued.path then
                local line = 'require\''
                if queued.type == 'global' then
                    line = queued.name .. ' = ' .. line
                end
                line = line .. queued.path:gsub(local_path:gsub('%.', '%%.'), '') .. '\''
                debug(1, 'Autoload line', line)
                file:write(line .. '\n')
            end
        end
        File.close(file)
        io.write('\nYou can now use generated file with:\nrequire\'lib.autoload\'\n')
    end,
}