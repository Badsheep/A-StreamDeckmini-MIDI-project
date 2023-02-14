

function MidiSearch(Name)
  
  local MidiDevicesList = hs.midi.devices()
  
  for i = 1, #MidiDevicesList do 
    --print(MidiDevicesList[i]) 
    if MidiDevicesList[i] == Name then
      --print(MidiDevicesList[i] .. ' Numéro ' .. i)
      return i
    end
  end
end

function CompON(MidiPort)
  MidiPort:sendCommand("controlChange", {
    ["controllerNumber"] = 4,
    ["controllerValue"] = 00000000000000,
    ["channel"] = 0,
}) 

end


function CompOFF(MidiPort)
  MidiPort:sendCommand("controlChange", {
    ["controllerNumber"] = 4,
    ["controllerValue"] = 11111111111111,
    ["channel"] = 0,
}) 

end

function VinyleON(MidiPort)
  MidiPort:sendCommand("controlChange", {
    ["controllerNumber"] = 2,
    ["controllerValue"] = 00000000000000,
    ["channel"] = 0,
}) 

end


function VinyleOFF(MidiPort)
  MidiPort:sendCommand("controlChange", {
    ["controllerNumber"] = 2,
    ["controllerValue"] = 11111111111111,
    ["channel"] = 0,
}) 

end



