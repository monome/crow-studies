-- crow example 1
-- setting output

local volts = 0

function init()
  crow.output[1].volts = volts
  screen.level(15)
  screen.aa(0)
  screen.line_width(1)
end

function redraw()
  screen.clear()
  screen.move(10,40)
  screen.text("volts: "..string.format("%.3f",volts))
  screen.update()
end

function enc(n,z)
  if n==2 then
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
