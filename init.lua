-- created by Badsheep
-- february 2023

-- I'm a beginner in those kinf of stuffs so please don't judge me bad
-- The goal is to exchange Midi Datas between a Stresm Deck Mini and MAX (Cycling 74)
-- I uses Midi Control Change (n°2 and n°4)
-- 2 functions :
-- Activate the audio inputs of the soundcard to be able to hear a vinyl turntable connected on it
-- Activate a compressor on the audio output.

-- inspirations :
-- https://github.com/peterhajas/dotfiles/tree/master/hammerspoon/.hammerspoon
-- https://gist.github.com/llimllib/137c587eba2ce9b0eff2c9af4d0a5e29


require "midi"
require "icons"


streamdeck = nil
isConnected = nil
streamdeckState = nil

-- CREATE MIDI OBJECTS

-- MAX creates it own Midi ports In and Out
-- To send Midi datas from SDM to MAX I use this virtual source

fromMax = hs.midi.newVirtualSource(hs.midi.virtualSources()[2])

-- I can't use the virtual input Midi port created by MAX, because for now Hammerspoon can handle virtual sources but not destinations.
-- So I use created a MIDI port in the IAC Driver, and I use it as an input in MAX.
-- then Hammerspoon sees it as a MIDI device.

DeviceNumber = MidiSearch('Gestionnaire IAC')
toMax = hs.midi.new(hs.midi.devices()[DeviceNumber])


function initialState()
  
  -- With 'ON' or 'OFF' I set the initial state of the functions (vinyle is off and compressor is off)
  streamdeckState = {'OFF', 'OFF', 'OFF', 'OFF', 'OFF' , 'OFF'}
  streamdeck:setButtonImage(1, Button1OFF())
  streamdeck:setButtonImage(3, Button3OFF())

end

-- MIDI Callback to return the state of the functions in MAX to SDM
-- I sometimes recall thoses functions in MAX directly or from an Harmony Remote, so the SDM needs to have a state up-to-date

function ReceivedMidi(object, deviceName, commandType, description, metadata)

  --print("object: " .. tostring(object))
  --print("deviceName: " .. deviceName)
  --print("commandType: " .. commandType)
  --print("description: " .. description)
  --print("metadata: " .. hs.inspect(metadata))

  if metadata["controllerNumber"] == 4 then
    if metadata["controllerValue"] == 127 then
      if streamdeckState[1] == 'ON' then
        streamdeck:setButtonImage(1, Button1OFF())
        streamdeckState[1] = 'OFF'
      end
    elseif metadata["controllerValue"] == 0 then
      if streamdeckState[1] == 'OFF' then
        streamdeck:setButtonImage(1, Button1ON())
        streamdeckState[1] = 'ON'
      end
    end
  elseif metadata["controllerNumber"] == 2 then
    if metadata["controllerValue"] == 127 then
      if streamdeckState[3] == 'ON' then
        streamdeck:setButtonImage(3, Button3OFF())
        streamdeckState[3] = 'OFF'
      end
    elseif metadata["controllerValue"] == 0 then
      if streamdeckState[3] == 'OFF' then
        streamdeck:setButtonImage(3, Button3ON())
        streamdeckState[3] = 'ON'
      end
    end
  end
end

function deckButton(device, buttonId, isPressed)
  
  -- the isPressed condition is here to avoid to have double request, as the SDM send datas on press AND on release       
  if buttonId == 3 and isPressed == true then
    
    if streamdeckState[3] == 'OFF' then
      --hs.alert.show("Vinyle ON")
      VinyleON(toMax)
      streamdeck:setButtonImage(3, Button3ON())
      streamdeckState[3] = 'ON'
    
    elseif streamdeckState[3] == 'ON' then
      --hs.alert.show("Vinyle OFF")
      VinyleOFF(toMax)
      streamdeck:setButtonImage(3, Button3OFF())
      streamdeckState[3] = 'OFF'
    end
  end
  
  if buttonId == 1 and isPressed == true then
    
    if streamdeckState[1] == 'OFF' then
      --hs.alert.show("Comp ON")
      CompON(toMax)
      streamdeck:setButtonImage(1, Button1ON())
      streamdeckState[1] = 'ON'
    
    elseif streamdeckState[1] == 'ON' then
      --hs.alert.show("Comp OFF")
      CompOFF(toMax)
      streamdeck:setButtonImage(1, Button1OFF())
      streamdeckState[1] = 'OFF'
    end
  end
end

function discoveryCallback(connected, device)
  
  if connected then
    isConnected = true
    streamdeck = device
    streamdeck:reset()
        
    -- INITIAL STATE
        
    initialState()
    
    -- START CALLBACK SDM
        
    streamdeck:buttonCallback(deckButton)
    
    -- START CALLBACK MIDI FROM MAX
        
    fromMax:callback(ReceivedMidi)

    print("Streamdeck connected")
    
    
  else
    isConnected = false
    streamdeck = nil
    print("Streamdeck disconnected")
  end
  
end

-- START STREAM DESK DISCOVERY

hs.streamdeck.init(discoveryCallback)


