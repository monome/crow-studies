-- rising: crow study 1
-- setting output
--
-- E1 adjust slew time
-- E2 adjust volt
-- E3 adjust volt (fine)

local volts = 0
local slew = 0

function init()
  crow.output[1].volts = volts
  crow.output[1].slew = slew
  screen.level(15)
  screen.aa(0)
  screen.line_width(1)
end

function redraw()
  screen.clear()
  screen.move(10,40)
  screen.text("volts: "..string.format("%.2f",volts))
  screen.move(10,50)
  screen.text("slew: " ..string.format("%.2f",slew))
  screen.update()
end

function enc(n,z)
  if n==1 then
    slew = util.clamp(slew + z*0.25,0,10)
    crow.output[1].slew = slew
  elseif n==2 then
    volts = util.clamp(volts + z*1,-5,10)
    crow.output[1].volts = volts
   elseif n==3 then
    volts = util.clamp(volts+ z*0.01,-5,10)
    crow.output[1].volts = volts
  end
  redraw()
end 

function key(n,z)
  if n==2 and z==1 then
    volts = 0
    crow.output[1].volts = volts
  elseif n==3 and z==1 then
    volts = math.random(12) / 12
    crow.output[1].volts = volts
  end
  redraw()
end
