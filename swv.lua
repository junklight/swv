-- Sine Waves for Disquiet Junto 
-- five notes 
-- that's it 
engine.name = 'SWV'
local ControlSpec = require "controlspec"
local Formatters = require "formatters"
local g = grid.connect()
local grd = 1

local FREQ = ControlSpec.new(10, 400, "lin", 0, 150, "Hz")
local SPREAD = ControlSpec.new(0, 15, "lin", 0, 5, "Hz")

local ncoord = { 
    0,0,0,0,0
  }
  
local nstate = {
  2,2,2,2,2
}

-- I was going to make all this setable with encoders 
-- but for today's puroses I think just setting them  in the code 
-- might be fine 

local center_freq = 150
local freq_spread = 0.4

function get_freq(n)
  return ( center_freq - (2 * freq_spread)) + ((n - 1)  * freq_spread)
end

local npans = { 
  -1.0,-0.5,0.0,0.5,1.0
  }

function init()
  params:add{type = "control", id = "freq", name = "freq", controlspec = FREQ, formatter = Formatters.format_freq, 
    action = function(n)
      center_freq = n
      print("freq ", center_freq)
      for nte = 1,5 do
        engine.freq(nte,get_freq(n))
      end
    end
  }
  params:add{type = "control", id = "spread", name = "spread", controlspec = SPREAD, formatter = Formatters.format_freq, 
    action = function(n)
      freq_spread = n
      for nte = 1,5 do
        engine.freq(nte,get_freq(n))
      end
    end
  }
  gridredraw()
end

function do_note(n,y)
  if nstate[n] == 2 then 
    nstate[n] =  5 + (6-y)
    engine.note_on(n,get_freq(n),(y/7.0) * 1.0 )
    print("note on",n,get_freq(n),(y/7.0) * 1.0)
    engine.pan(n,npans[n])
  else 
    nstate[n] = 2
    engine.note_off(n)
    print("note off",n)
  end
end

function g.key(x, y, z)
  if z == 1 then 
    for nte = 1,5 do
      if x >= ncoord[nte] and x <= ncoord[nte] + 1 then 
        if y > 1 and y < 8 then 
          do_note(nte,y)
        end
      end
    end
  end
  gridredraw()
  redraw()
end

function gridredraw()
  g:all(0)
  for nte = 1,5 do 
    startx = ((nte -1 ) * 3) + 2
    ncoord[nte] = startx
    for x = startx,startx +1 do 
      for y = 2,7 do
        g:led(x,y,nstate[nte])
      end
    end
  end 
  
  g:refresh()
end

function enc(n, delta)
   if n == 1 then
    mix:delta("output", delta)
  elseif n == 2 then 
    params:delta("freq", delta)
  elseif n == 3 then 
    params:delta("spread", delta)    
  end
  redraw()
end

function key(n,z)
  
  redraw()
end

function redraw()
  screen.clear()
  screen.move(10,30)
  screen.text("freq " .. params:get("freq"))
  screen.move(10,40)
  screen.text("spread " .. params:get("spread"))
  screen.update()
end

function cleanup ()
  for nte = 1,5 do 
    engine.note_off(nte)
  end
end
