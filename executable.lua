#!/usr/bin/env lua

require'lib.autoload'

--[[ //////////////////////////////////// ]]

CLI.executable = 'stanley'
CLI.version = '1.1'

CLI.options = {
    source = {
        description = 'Set source for newly required package.\n\tAppended to every repository that does not have source specified.',
        alias = 's',
        default = 'https://github.com/'
    },
    target = {
        description = 'Set target directory for newly required package.\n\tGit clone will download files there.',
        alias = 't',
        default = ''
    },
    verbose = {
        description = 'Enable verbose mode (print debug messages).\n\tThe higher the value, the deeper you dig.',
        alias = 'v',
        default = 0
    },
    version = {
        description = 'Print current version and exit.',
        default = false
    }
}

CLI.help = {
    'Git-based package manager for Lua.',
    '\nUsage: %EXEC% [options] command [repo]',
    '\nAvailable commands:',
    CLI.printCommands,
    '\nAvailable options:',
    CLI.printOptions,
}

CLI.commands = {
    help = { 'Show this message.', function()
        CLI:printHelp()
    end},

    init = { 'Create package.yaml in current working directory.', function()
        Stanley:initializePackage()
    end},

    require = { 'Add package to required list.', function(repo, ...)
        Stanley:requirePackages(repo, ...)
    end},

    remove = { 'Remove package from required list.', function(repo)
        Stanley:removePackages(repo)
    end},

    update = { 'Clone or pull all required packages from remote sources.', function()
        Stanley:updatePackages()
    end},

    dump = { 'Generate ./lib/autoload.lua file.', function()
        Stanley:generateAutoloadFile()
    end},

    install = { 'Alias for: stanley update && stanley dump', function()
        Stanley:updatePackages()
        Stanley:initialize()
        Stanley:generateAutoloadFile()
    end},
}

-- This is where the fun begins. :)
CLI:init()
debug.verbose = CLI:getOption('verbose')
debug(2, 'Parsed options', CLI.options)
debug(2, 'Parsed args', CLI.args)
if CLI:getOption('version') then
    CLI:printVersion()
    os.exit()
end
xpcall(function()

    Stanley:initialize()

    if #CLI.args > 0 then
        local Command = CLI.args[1]
        table.remove(CLI.args, 1)
        CLI:issueCommand(Command)
    else
        CLI:issueCommand('help')
    end

end, function(err)
    -- Custom error handling
    local file = err:match('^(%D+):')
    local line = err:match('^%D+:(%d+)')
    local message = err:sub(err:match('^.*():') + 2)
    debug('\n[Error] ' .. file .. ' {' .. line .. '}')
    io.output(io.stderr)
    io.write(message .. '\n')
end)
