-- rising: crow study 4
-- shapes (advanced output)
--
-- output 1 = LFO
-- output 2 = envelope
--
-- K2 randomizes LFO
-- K3 triggers envelope

local scope = {0,0}
local rate = 1

function init()
  crow.output[1].receive = function(v) out(1,v) end
  crow.output[2].receive = function(v) out(2,v) end
  
  r = metro.init()
  r.time = 0.05 
  r.event = function()
    crow.output[1].query()
    crow.output[2].query()
    redraw()
  end
  r:start()
  
  screen.level(15)
  screen.aa(0)
  screen.line_width(1)
end

function out(i,v)
  scope[i] = v
end

function redraw()
  screen.clear()
  screen.move(10,40)
  screen.text("1. lfo rate: "..string.format("%.1f",rate))
  screen.move(10,50)
  --screen.text(": "..string.format("%.3f",slew))

  screen.move(2,40)
  screen.line_rel(0,scope[1]*-4)
  screen.stroke()
  screen.move(4,40)
  screen.line_rel(0,scope[2]*-4)
  screen.stroke()
 
  screen.update()
end

function key(n,z)
  if n==2 and z==1 then
    rate = 0.1 + math.random(10)/10
    crow.output[1].action = "lfo("..rate..",4)"
    crow.output[1].execute()
  elseif n==3 and z==1 then
    crow.output[2].action = "{to(8,0.15),to(0,1)}"
    crow.output[2].execute()
  end
  redraw()
end
