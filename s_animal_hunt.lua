AnimalHunt = {}
AnimalHunt.__index = AnimalHunt
State = {peace=0,warning=1,danger=2}
function AnimalHunt:create()
    
    local self = setmetatable({}, AnimalHunt)

    self.ped = nil --createPed(141, x, y, z)
    self.blip = nil --createBlipAttachedTo(self.ped, 0)
    self.marker = nil --createMarker(x, y, z - 1, "cylinder", 2.0, 255, 0, 0, 150)
    self.timer = nil
    self.Aspects =  { 300, 301, 311, 1 }
    self.Accion = {"caminar","RUN_civi","SPRINT_civi"}
    self.State = State.peace;

    -- Asociar marker con este objeto
    setElementData(self.marker, "animalHunt", self)
    
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


function AnimalHunt:deletePed(ped)
    setTimer(function()
       if isElement(self.ped) then
           destroyElement(self.ped)
       end
   end, 10000, 1) -- 5 segundos de delay
end

function AnimalHunt:changeAnimation(i)
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

    end
 end 
 
function AnimalHunt:checkLife()
    local vida = getElementHealth(self.ped)
        if vida and vida <= 70 then
           return true
        else
           return false
       end
end

function AnimalHunt:huntingBounty(cause,source)
    --aqui se entregara la reconpenza
    local x, y, z = getElementPosition(self.ped)    
    local money = createPickup(x, y, z, 3, 1212)
    
     addEventHandler("onPickupHit", money, function(source) --el evecto que se acciona al recoger el objeto
        givePlayerMoney(source, cause)
        destroyElement(money)
    end)
     
end

function AnimalHunt:EntroEnArea()
    addEventHandler("onMarkerHit", self.marker, function(hitElement)--el hit element es el plauyer
        if getElementType(hitElement) == "player" then
            triggerEvent("onAnimalHuntMarkerHit", resourceRoot, self, hitElement)
            self:startTimer()
            destroyElement(self.marker)
        end
    end)
end

function AnimalHunt:RecibeDanoElPed()
    addEventHandler("onPedDamage", ped, function()
                     
        if  self.State == 1  then 
         firstWarning(ped,blip,marker,1,player)       
        else  
            if not warning then
               --el ped recibe una segunda bala
                 warning=checkLife(ped)
                 calcRotation(ped)   
                
             else
                --este es el "Proceso de Orientacion"
              
                calcRotation(ped)

            end

        end

             --se inicia otro timmmer
    end)
end


function firstWarning(i,player)
    cancelTimer(ped) --se cancela el timer anterior de espera
    destroyElement(self.blip)
    self.calcRotation()

        if not self.checkLife() then --se chequea la vida y en caso de no estar alerta el animal camina
            self.changeAnimation(i)
        end

    removeProximitySensor(marker)--seria buena idea dejar el marker en el ped?
    huntingTime(ped) --se cancela el timer de espera y se crea uno nuevo de caza
   return true
end

function AnimalHunt:CalcRotation()
    x1, y1, a = getElementPosition(self.ped)
    
    local indiceAleatorio = math.random(1, #posiciones)
    local x2,y2,a,b =unpack(posiciones[indiceAleatorio])  

    local angulo = math.deg(math.atan2(x2 - x1, y2 - y1))
    local rotacion = (angulo + 180) % 360
      
        setElementRotation(self.ped, 0, 0, rotacion)
end

    function crearPedEnPosicion(x1, y1, z1, rotacion, player, radio, typeAnimal)
    
    
        if ped then
                setElementData(ped, "npc", player)
                
                  local marker = createMarker(x1, y1, z1, "cylinder", radio, 255, 162, 51, 0)
                  local blip = createBlipPed(x1, y1, z1)
             
                createProximitySensor(ped, marker,blip,player)
                createAndSetTimer(ped,marker,blip)
    
                  local warningBool=false
                  local  warning=false
           
                
                addEventHandler("onPedWasted", ped, function(totalAmmo, killer, killerWeapon, bodypart)
                    cancelTimer(ped)
                   local cause =  causeOfDeath(killer)
                    huntingBounty(cause,ped,source)
                      
                     deletePed(ped)
                end)
    
                return ped
            
            else
           
            return false
            
        end
    end
    