-- lfo quantizer for jf + crow
-- plug an LFO into input 1
-- use a crow output
-- ii -> JF
--
-- connect JF via ii
-- crow in 1: clock
-- crow in 2: LFO to quantize
--
-- enc 2+3: min/max thresholds
-- key 2: random min/max

m = require 'musicutil'

local note = 1
local scale = m.generate_scale(0,"dorian",2)
local ExtMin = 0
local ExtMax = 10
local ExtRange = ExtMax - ExtMin

function init()
  -- keep the line below only if you don't have a 
  -- powered busboard or teletype connected to your ii network
  crow.II.pullup(true)
  crow.II.jf.mode(1)
  screen.level(15)
  screen.aa(0)
  screen.line_width(1)
  crow.input[1].mode("change")
  crow.input[1].change = change
  crow.input[2].mode("none")
  crow.input[2].stream = stream
end

function redraw()
  screen.clear()
  screen.move(10,40)
  screen.text("note: "..scale[note])
  screen.move(10,50)
  screen.text("min: "..string.format("%.1f",ExtMin).."v")
  screen.move(10,60)
  screen.text("max: "..string.format("%.1f",ExtMax).."v")
  screen.update()
end

function change(s)
  if s == 1 then
    crow.input[2].query()
    redraw()
  end
end

function stream(v)
  ExtRange = ExtMax - ExtMin
  note = math.floor(((((v - (ExtMin)) * (#scale-1)) / ExtRange) + 1) + 0.5)
  if note <= #scale and note >= 1 then
    note = note
  elseif note >= # scale then
    note = #scale
  elseif note < 1 then
    note = 1
  end
  crow.II.jf.play_note(scale[note]/12-1,math.random(5)+1)
  redraw()
end

function enc(n,d)
  if n == 2 then
    ExtMin = util.clamp(ExtMin + d*0.5,-5,10)
  elseif n == 3 then
    ExtMax = util.clamp(ExtMax + d*0.5,-5,10)
  end
  redraw()
end

function key(n,z)
  if n == 2 and z == 1 then
    ExtMin = math.random(-5,10)
    ExtMax = math.random(-5,10)
  end
  redraw()
end
