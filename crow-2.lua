-- crow example 2
-- input query and stream
--
-- K2 query
-- K3 toggle mode

local volts = 0
local mode = "none"
local rate = 0.1

function init()
  crow.input[1].stream = stream
  crow.input[1].mode("none")
  screen.level(15)
  screen.aa(0)
  screen.line_width(1)
end

function stream(v)
  volts = v
  redraw()
end

function redraw()
  screen.clear()
  screen.move(10,40)
  screen.text("volts: "..string.format("%.3f",volts))
  screen.move(10,50)
  screen.text("mode: "..mode)
  screen.move(2,40)
  screen.line_rel(0,volts*-4)
  screen.stroke()
  screen.update()
end

function key(n,z)
  if n==2 and z==1 then
    crow.input[1].query()
  elseif n==3 and z==1 then
    mode = (mode=="none" and "stream" or "none") 
    crow.input[1].mode(mode)
    redraw()
  end
end 

