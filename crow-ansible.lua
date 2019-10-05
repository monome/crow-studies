-- crow-ansible
-- testing output to ansible
--
-- ENC2 and grid row 7 affects crow output 1
-- ENC3 and grid row 8 affects ansible cv channel 1

-- devices
local g = grid.connect()
crow.ii.pullup(true)

local MIN_VOLTS = 0
local MAX_VOLTS = 10

local volts = 0
local ansible_volts = 0
local ansible_channel = 0 -- note that channel ONE on the ansible is 0 in code

local function clear_grid()
    for y = 1, 8 do
        for x = 1, 16 do
            g:led(x, y, 0)
        end
    end
end

local function volts_to_grid_row(v)
    return util.round(util.linlin(MIN_VOLTS, MAX_VOLTS, 1, 16, v))
end

local function grid_pos_to_volts(x_pos)
    return util.linlin(1, 16, MIN_VOLTS, MAX_VOLTS, x_pos)
end

local function light_row_by_volts(v, row_num)
    local level = volts_to_grid_row(v)
    for i = 1, level do
        g:led(i, row_num, i - 1)
    end
end

local function redraw_grid()
    clear_grid()

    light_row_by_volts(volts, 7)
    light_row_by_volts(ansible_volts, 8)

    g:refresh()
end

local function update_voltage()
    crow.output[1].volts = volts
    crow.ii.ansible.cv(ansible_channel, ansible_volts)
end

function init()
    crow.output[1].slew = 0
    crow.ii.ansible.cv_slew(0, 0)
end

function enc(n, d)
    if n == 2 then
        volts = util.clamp(volts + (d * 0.2), MIN_VOLTS, MAX_VOLTS)
    end
    if n == 3 then
        ansible_volts = util.clamp(ansible_volts + (d * 0.2), MIN_VOLTS, MAX_VOLTS)
    end

    update_voltage()

    redraw_grid()
    redraw()
end

function key(n, z)
    print(n .. "," .. z)
    redraw_grid()
    redraw()
end

g.key = function(x, y, z)
    if (y == 8) then
        ansible_volts = grid_pos_to_volts(x)
    end
    if (y == 7) then
        volts = grid_pos_to_volts(x)
    end

    update_voltage()

    redraw_grid()
    redraw()
end

function redraw()
    screen.clear()

    screen.move(6, 24)
    screen.text("crow ch 1 output:  " .. volts)

    screen.move(6, 36)
    screen.text("ansible ch 1 output:  " .. ansible_volts)

    screen.update()
end
