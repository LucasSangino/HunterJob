

function inicio(typeAnimal)
local animal = AnimalHunt:create()
    local indiceAleatorio = math.random(1, #posiciones)
        
        local x1, y1, z1, __ = unpack(posiciones[indiceAleatorio])
        local radio = 30.0
      --  local ped = crearPedEnPosicion(x1, y1, z1, rotacion, player, radio, typeAnimal)
    
    animal:SpawnPed(x1, y1, z1, typeAnimal)
    animal:CreateMarker(x1, y1, z1, radio)
    animal:CreateBlip(x1,y1,z1)
end

addEvent("createAnimalObj", true)

addEventHandler("createAnimalObj", root, function(typeAnimal)
       
    inicio(typeAnimal)
    
end)
