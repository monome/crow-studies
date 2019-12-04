-- crow example for ansible ii
-- (requires ansible)
--
-- E1 change channel / page
-- K3 toggles between CV and trigger
--
-- CV MODE:
-- E2 adjust ch 1 volt
-- E3 adjust ch 1 slew time
-- K2 hold to enable fine adjust of voltage
--
-- TRIGGER MODE:
-- E2 change pattern (per channel)
-- E3 change metro speed (global)
-- K2 start/stop metro (global)

local UI = require "ui"

cv = {
    volts = {0, 0, 0, 0},
    slew = {0, 0, 0, 0},
    fine_mode = false
}

tr = {
    all_ptns = {
        {1, 0, 0, 0, 0, 0, 0, 0},
        {1, 0, 0, 0, 1, 0, 0, 0},
        {1, 0, 1, 0, 1, 0, 1, 0},
        {1, 0, 1, 0, 1, 1, 1, 0},
        {1, 1, 0, 1, 1, 0, 1, 1},
        {1, 1, 1, 1, 1, 1, 1, 1}
    },
    ptn_length = 8,
    current_ptn = {1, 1, 1, 1},
    speed = 0.1,
    pulse_time = 5,
    is_running = false,
    pos = 1,
    seq = {}
}
tr.pulse = function()
    for i = 1, 4 do
        local ptn = tr.all_ptns[tr.current_ptn[i]]
        if ptn[tr.pos] == 1 then
            crow.ii.ansible.trigger_pulse(i)
        end
    end
    tr.pos = tr.pos + 1
    if tr.pos > 8 then
        tr.pos = 1
    end
end

local channel_pages, mode_tabs

local MODE_TR = 1
local MODE_CV = 2

function init()
    crow.ii.pullup(true)
    -- initialize cv, slew, and pulse time  across all four channels
    for i = 1, 4 do
        crow.ii.ansible.cv(i, cv.volts[i])
        crow.ii.ansible.cv_slew(i, cv.slew[i])
        crow.ii.ansible.trigger_time(i, tr.pulse_time)
    end
    tr.seq = metro.init(tr.pulse, tr.speed, -1)
    channel_pages = UI.Pages.new(1, 4)
    mode_tabs = {}
    for i = 1, 4 do
        mode_tabs[i] = UI.Tabs.new(2, {"tr", "cv"})
    end
end

function enc(n, z)
    if n == 1 then
        channel_pages:set_index_delta(util.clamp(z, -1, 1), false)
    end

    local channel = channel_pages.index

    if mode_tabs[channel].index == MODE_TR then
        if n == 2 then
            local new_pattern_index = tr.current_ptn[channel] + z
            if new_pattern_index <= #tr.all_ptns and new_pattern_index > 0 then
                tr.current_ptn[channel] = new_pattern_index
            end
        elseif n == 3 then
            tr.speed = util.clamp(tr.speed + (z * 0.05), 0.1, 2.0)
            tr.seq.props.time = tr.speed
        end
    end

    -- check if we're in cv mode for this channel
    if mode_tabs[channel].index == MODE_CV then
        if n == 2 then
            if cv.fine_mode then
                -- fine cv output
                cv.volts[channel] = util.clamp(cv.volts[channel] + z * 0.01, 0, 10)
                crow.ii.ansible.cv(channel, cv.volts[channel])
            else
                -- coarse cv output
                -- note that unlike crow, ansible can only output 0 to 10v, not -5 to 10v
                cv.volts[channel] = util.clamp(cv.volts[channel] + z * 1, 0, 10)
                crow.ii.ansible.cv(channel, cv.volts[channel])
            end
        elseif n == 3 then
            -- slew value
            cv.slew[channel] = util.clamp(cv.slew[channel] + z * 0.25, 0, 10)
            crow.ii.ansible.cv_slew(channel, cv.slew[channel])
        end
    end

    redraw()
end

function key(n, z)
    local channel = channel_pages.index

    if n == 3 and z == 1 then
        for i = 1, 4 do
            mode_tabs[i]:set_index_delta(1, true)
        end
    end

    if mode_tabs[channel].index == MODE_TR then
        if n == 2 and z == 1 then
            if tr.is_running then
                tr.seq:stop()
                tr.is_running = false
                for i = 1, 4 do
                    crow.ii.ansible.trigger(i, 0)
                end
            else
                tr.seq:start()
                tr.is_running = true
            end
        end
    end

    -- check if we're in cv mode for this channel
    if mode_tabs[channel].index == MODE_CV then
        if n == 2 then
            if z == 1 then
                cv.fine_mode = true
            else
                cv.fine_mode = false
            end
        end
    end

    redraw()
end

function redraw()
    screen.clear()
    channel_pages:redraw()

    local channel = channel_pages.index
    mode_tabs[channel]:redraw()

    screen.level(12)
    screen.aa(0)
    screen.line_width(1)

    if mode_tabs[channel].index == MODE_CV then
        screen.move(10, 18)
        screen.text("ansible channel        " .. channel)
        screen.move(10, 38)
        screen.text("volts: " .. string.format("%.2f", cv.volts[channel]))
        screen.move(10, 48)
        screen.text("slew: " .. string.format("%.2f", cv.slew[channel]))
    else
        screen.move(10, 18)
        screen.text("ansible channel        " .. channel)
        screen.move(10, 38)
        screen.text("pattern #: " .. tr.current_ptn[channel])
        if tr.is_running then
            screen.move(10, 48)
            screen.text("running")
        end
    end

    screen.update()
end
