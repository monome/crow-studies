-- crow example for ansible
-- (requires ansible)
--
-- E1 adjust ch 1 slew time
-- E2 adjust ch 1 volt
-- E3 adjust ch 1 volt (fine)
-- K2 changes the ansible channel
-- K3 zeros out all outputs

local volts = 0
local slew = 0

-- note that channel *1* on the ansible panel is *0* in code
-- as of v1.0.0 of crow
local ansible_channel = 0
local num_channels = 3

function init()
    crow.ii.pullup(true)
    crow.ii.ansible.cv(ansible_channel, volts)
    crow.ii.ansible.cv_slew(ansible_channel, slew)

    screen.level(15)
    screen.aa(0)
    screen.line_width(1)
end

function redraw()
    screen.clear()
    screen.move(10, 10)
    screen.text("ansible channel        " .. ansible_channel + 1)
    screen.move(10, 30)
    screen.text("volts: " .. string.format("%.2f", volts))
    screen.move(10, 40)
    screen.text("slew: " .. string.format("%.2f", slew))

    screen.update()
end

function enc(n, z)
    if n == 1 then
        -- slew value
        slew = util.clamp(slew + z * 0.25, 0, 10)
        crow.ii.ansible.cv_slew(ansible_channel, slew)
    elseif n == 2 then
        -- course cv output
        -- note that unlike crow, ansible can only output 0 to 10v, not -5 to 10v
        volts = util.clamp(volts + z * 1, 0, 10)
        crow.ii.ansible.cv(ansible_channel, volts)
    elseif n == 3 then
        -- fine cv output
        volts = util.clamp(volts + z * 0.01, 0, 10)
        crow.ii.ansible.cv(ansible_channel, volts)
    end
    redraw()
end

function key(n, z)
    if (n == 2 and z == 1) then
        -- change channels
        if (ansible_channel < num_channels) then
            ansible_channel = ansible_channel + 1
        else
            ansible_channel = 0
        end
    end
    if (n == 3 and z == 1) then
        -- zero out all the outputs
        volts = 0
        for i = 0, num_channels do
            crow.ii.ansible.cv(i, volts)
        end
    end
    redraw()
end
