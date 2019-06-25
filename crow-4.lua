-- crow example 4
-- simple grid-based monophonic keyboard
--
-- (requires grid)
--
-- out 1 => oscillator pitch
-- out 2 => env gate in

local g = grid.connect()
local lit = {}

function init()
  if g then gridredraw() end
end

function g.key(x, y, z)
  grid_note{
    id = x*8 + y,
    x = x,
    y = y,
    state = z
  }
  gridredraw()
end

function grid_note(e)
  if e.state > 0 then
    local note = ((7-e.y)*5) + e.x
    -- equal temp
    crow.output[1].volts = note * 0.083333333333333
    -- 'gate' out
    crow.output[2].volts = 5.0
      
    lit[e.id] = {
      x = e.x,
      y = e.y
    }
  else
    crow.output[2].volts = 0
    if lit[e.id] then
      lit[e.id] = nil
    end
  end
  gridredraw()
end

function gridredraw()
  g:all(0)
  for _,e in pairs(lit) do
    g:led(e.x, e.y, 15)
  end

  g:refresh()
end
