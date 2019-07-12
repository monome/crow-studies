-- crow example 4
-- advanced output
--
-- connect output 1 to input 1
--   for a scope

local volts = 0
local slew = 0
local scope = 0

function init()
  crow.output[1].volts = volts

  crow.input[1].mode("stream")
  crow.input[1].stream = stream

  screen.level(15)
  screen.aa(0)
  screen.line_width(1)
end

function stream(v)
  scope = v
  redraw()
end

function redraw()
  screen.clear()
  screen.move(10,40)
  screen.text("volts: "..string.format("%.3f",volts))
  screen.move(10,50)
  screen.text("slew: "..string.format("%.3f",slew))

  screen.move(2,40)
  screen.line_rel(0,scope*-4)
  screen.stroke()

  screen.update()
end

function enc(n,z)
  if n==2 then
    volts = util.clamp(volts + z*1,-5,10)
    crow.output[1].volts = volts
   elseif n==3 then
    slew = util.clamp(slew + z*0.1,0,5)
    crow.output[1].slew = slew
  end
  redraw()
end 

function key(n,z)
  if n==2 and z==1 then
    crow.output[1].action = "lfo(2,0.5)"
    crow.output[1].execute()
  elseif n==3 and z==1 then
    crow.output[1].action = "{to(8,0.25),to(0,2)}"
    crow.output[1].execute()
  end
  redraw()
end
