--[[
    before running execute:
    $ ./stanley update
    $ ./stanley dump
    so that required 'lib.autoload' file gets created
]]

function love.load()
    require'lib.autoload'

    -- example Hump.Class usage
    local some_class = Class {
        min = 100,
        max = 200
    }

    -- Example Lume usage
    print(Utils.lerp(some_class.min, some_class.max, 0.5))

    love.event.quit()
end