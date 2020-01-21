-- rising: crow study 5
-- construct (extended shapes)
-- ~  ~  ~  ~
-- four linked lfos
-- with variable stages + shapes
--
-- E1: change base time
-- K2: construct new
-- K3: restart current

local scope = {0,0,0,0}

function init()
  shapes = {'linear','sine','logarithmic','exponential','now','wait','over','under','rebound'}
  base_time = 1200
  start_menu = true
  
  wave = {}
  for i = 1,4 do
    wave[i] = {}
    wave[i].full = {}
    for j=1,5 do
      wave[i][j] = {}
      wave[i][j].volt = 0
      wave[i][j].slew = 0
      wave[i][j].shape = 0
      wave[i][j].to = nil
    end
  end
  
  for i = 1,4 do
    crow.output[i].receive = function(v) outs(i,v) end
  end
  
  r = metro.init()
  r.time = 0.01
  r.event = function()
    for i = 1,4 do
      crow.output[i].query()
    end
    redraw()
  end
  r:start()
  
  screen.level(15)
  screen.aa(0)
  screen.line_width(1)
  
end

function outs(i,v)
  scope[i] = v
end

function key(n,z)
  if z == 1 then
    if n == 2 then
      if start_menu == true then start_menu = false end
      for i = 1,4 do
        for j = 1,5 do
          wave[i][j].volt = math.random(-5000,10000)/1000
          wave[i][1].volt = 0
          wave[i][5].volt = 0
          wave[i][j].slew = (base_time/(math.random(4)))/1000
          wave[i][j].shape = shapes[math.random(9)]
          wave[i][j].to = "to(" .. wave[i][j].volt .. "," .. wave[i][j].slew .. "," .. wave[i][j].shape .. ")"
        end
        wave[i].full = "loop( { "..wave[i][1].to..","..wave[i][2].to..","..wave[i][3].to..","..wave[i][4].to..","..wave[i][5].to.."} )"
        crow.output[i].volts = 0
        crow.output[i].action = wave[i].full
        crow.output[i].execute()
      end
    elseif n == 3 then
      for i = 1,4 do
        crow.output[i].volts = 0
        crow.output[i].action = wave[i].full
        crow.output[i].execute()
      end
    end
  redraw()
  end
end

function enc(n,d)
  if n == 1 then
    base_time = util.clamp(base_time+d*10,1,10000)
    redraw()
  end
end

function redraw()
  screen.clear()
  if start_menu == true then
    screen.move(10,40)
    screen.text("[press K2 to start]")
  else
    for i = 1,4 do
      screen.move(10*i,40)
      screen.line_rel(0,scope[i]*-4)
      screen.stroke()
    end
    screen.move(70,30)
    screen.text("E1: "..base_time.."ms")
    screen.move(70,40)
    screen.text("K2: new")
    screen.move(70,50)
    screen.text("K3: restart")
  end
  screen.update()
end