AnimalHunt = {}
AnimalHunt.__index = AnimalHunt

function AnimalHunt:create(x, y, z)
    
    local self = setmetatable({}, AnimalHunt)

    self.ped = nil --createPed(141, x, y, z)
    self.blip = nil --createBlipAttachedTo(self.ped, 0)
    self.marker = nil --createMarker(x, y, z - 1, "cylinder", 2.0, 255, 0, 0, 150)
    self.timer = nil
    self.Aspects =  { 300, 301, 311, 1 }
    self.Accion = {"RUN_civi","SPRINT_civi"}
    -- Asociar marker con este objeto
    setElementData(self.marker, "animalHunt", self)

    addEventHandler("onMarkerHit", self.marker, function(hitElement)--el hit element es el plauyer
        if getElementType(hitElement) == "player" then
            triggerEvent("onAnimalHuntMarkerHit", resourceRoot, self, hitElement)
            self:startTimer()
            destroyElement(self.marker)
        end
    end)

    return self
end



function AnimalHunt:startTimer()
    self.timer = setTimer(function()
        triggerEvent("onAnimalHuntExpired", resourceRoot, self)
        self:destroy()
    end, 5000, 1) -- 5 segundos
end

function AnimalHunt:destroy()
    if isElement(self.ped) then destroyElement(self.ped) end
    if isElement(self.blip) then destroyElement(self.blip) end
    if isTimer(self.timer) then killTimer(self.timer) end
end

function AnimalHunt:CreatePed(x,y,z,typeAnimal)
    self.ped = createPed(self.Aspects[typeAnimal], x, y, z)
    setElementHealth(self.ped, 100)

end

function AnimalHunt:CreateMarker(x,y,z,radio)
    self.marker = createMarker(x, y, z , "cylinder", radio, 255, 162, 51, 0)
    attachElements(self.marker, self.ped, 0, 0, 0)

    --aca se activa el sensor de proximidad
   -- addEventHandler("onMarkerHit", self.marker, function(hitElement, matchingDimension)
   --     if not matchingDimension then return end
    --    if getElementType(hitElement) ~= "player" then return end
        
        --firstWarning(self.ped, self.blip, self.marker, 1, hitElement)

   -- end)
end 

function AnimalHunt:CreateBlip(x,y,z)
    self.blip = createBlip(x, y, z)
    setBlipColor(self.blip, 0, 255, 0, 255)
    setBlipSize(self.blip, 2)
   
end

funcion AnimalHunt:CreateAndSetTimmer()
    self.timer = setTimer(function()
        
        destroyElement(self.marker)
        destroyElement(self.blip)
        killTimer(self.timer)
    
    end
    ,300000,1)
    setElementData(self.ped, "deleteTimer", self.timer)

end


function deletePed(ped)
    setTimer(function()
       if isElement(self.ped) then
           destroyElement(self.ped)
       end
   end, 10000, 1) -- 5 segundos de delay
end

function changeAnimation(i)
    if i<=4 then
             --setElementHealth(ped, 100)  
             setPedAnimation(
             self.ped,--ped 
             "ped",-- bloque
             self.Accion[i],-- animacion
             -1,-- tiempo
             true,-- loop
             true,-- updatePosition 
             false,-- interruptible 
             true )-- freezeLastFrame

    else 
end  
end