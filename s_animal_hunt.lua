AnimalHunt = {}
AnimalHunt.__index = AnimalHunt

posiciones = {
    { -1754.935546875,  -1864.0048828125, 88.095001220703, 0 },
    { -1125.248046875,  -2421.1162109375, 80.637603759766, 0 },
    { -1696.2158203125, -1946.3994140625, 104.8030166626,  0 },
    { -1371.9326171875, -2738.560546875,  87.689270019531, 0 },
    { -910.8251953125,  -2520.9287109375, 119.1298828125,  0 },
    { -975.6396484375,  -2187.984375,     41.6252784729,   0 },
    { -847.453125,      -2315.23046875,   30.323818206787, 0 },
    { -1684.869140625,  -2422.1982421875, 103.75692749023, 0 },
    { -1307.486328125,  -2438.8271484375, 23.657644271851, 0 }
}
listIds = { 300, 301, 311, 1 }

State = {peace=1, warning=2, danger=3}

function AnimalHunt:create()
    local self = setmetatable({}, AnimalHunt)

    self.ped = nil
    self.blip = nil
    self.marker = nil
    self.Accion = { "walk_civi", "RUN_civi", "SPRINT_civi" }
    self.State = State.peace
    self.huntingTimer = nil
    self.timer = nil
    self.timerFor = nil
    self.timerActive = false
    self.disappearingTimer=nil

    return self
end



function AnimalHunt:destroy()
    self:KillerTimers()
    if isElement(self.ped) then destroyElement(self.ped) end
    if isElement(self.blip) then destroyElement(self.blip) end
    if isElement(self.marker) then destroyElement(self.marker) end

    self.ped, self.blip, self.marker = nil, nil, nil
end

function AnimalHunt:SpawnPed(x, y, z, typeAnimal)
    self.ped = createPed(listIds[typeAnimal], x, y, z)
    setElementHealth(self.ped, 100)
    self:RecibeDanoElPed()
    self:MuerteDelPed()
end

function AnimalHunt:CreateMarker(x, y, z, radio)
    self.marker = createMarker(x, y, z, "cylinder", radio, 255, 162, 51, 0)
    attachElements(self.marker, self.ped, 0, 0, 0)
    setElementData(self.marker, "animalHunt", self)
    self:EntroEnArea()
end 

function AnimalHunt:CreateBlip(x, y, z)
    self.blip = createBlip(x, y, z)
    setBlipColor(self.blip, 0, 255, 0, 255)
    setBlipSize(self.blip, 2)
end



function AnimalHunt:deletePed()
    setTimer(function()
        if isElement(self.ped) then
            destroyElement(self.ped)
        end
    end, 10000, 1)
end

function AnimalHunt:changeAnimation()
        setPedAnimation(
            self.ped,
            "ped",
            self.Accion[self.State],
            -1,
            true,
            true,
            false,
            true
        )

    outputChatBox(self.Accion[self.State])
    
end

function AnimalHunt:checkLife()
    local vida = getElementHealth(self.ped)
    if vida then
        if vida <= 70 then
            self.State = State.danger
            return true
        end
        if vida <= 90 then
            self.State = State.warning
            return true
        end
        
        self.State = State.peace
        return false
    end
end

function AnimalHunt:huntingBounty(cause, source)
    local x, y, z = getElementPosition(self.ped)
    local money = createPickup(x, y, z, 3, 1212)

    addEventHandler("onPickupHit", money, function(source)
        outputChatBox("Evento de dinero")
        givePlayerMoney(source, cause)
        destroyElement(money)
    end)
end

function AnimalHunt:causeOfDeath(killer, bodypart)

    local bonus = 10

    if killer and getElementType(killer) == "player" then
        --player
        bonus = 30
    elseif killer and getElementType(killer) == "vehicle" then
        -- "vehicle_kill"
        bonus = 5
    elseif bodypart == 9 then
        -- "fall"
        bonus = 5
    else
        --"other"
        bonus = 10
    end

    return bonus
end


function AnimalHunt:MuerteDelPed()
    addEventHandler("onPedWasted", self.ped, function(totalAmmo, killer, killerWeapon, bodypart)
        -- Validamos cada timer antes de intentar detenerlo para evitar errores
        self:KillerTimers()
        local cause = self:causeOfDeath(killer,bodypart)
        self:huntingBounty(cause, source)
        step=5
        interval=100
        fadeOutPed(step, interval)
    end)
end


function fadeOutPed( step, interval)
    step = step or 5           -- Cuánto reducir en cada paso (de 255 hacia 0)
    interval = interval or 100 -- Tiempo entre pasos en milisegundos

    local alpha = getElementAlpha(self.ped)
    if not alpha then return end

    self.disappearingTimer = setTimer(function()
        alpha = alpha - step
        if alpha <= 0 then
            alpha = 0
            setElementAlpha(slef.ped, alpha)
            slef:destroy()
        else
            setElementAlpha(self.ped, alpha)
        end
    end, interval, math.ceil(255 / step))

end

function AnimalHunt:DeletePed()
    if isElement(self.ped) then
        destroyElement(self.ped)
        self.ped = nil
    end    
end

function AnimalHunt:EntroEnArea()
    addEventHandler("onMarkerHit", self.marker, function(hitElement)
        if getElementType(hitElement) == "player" then
            triggerEvent("onAnimalHuntMarkerHit", resourceRoot, self, hitElement)
            outputChatBox("posicion")
            self:firstWarning()
        end
    end)
end


function AnimalHunt:RecibeDanoElPed()
    addEventHandler("onPedDamage", self.ped, function()
        outputChatBox("Evento daño al ped")
       -- killTimer(self.disappearingTimer)--elimino el 
        if self.State == State.peace then 
            self:firstWarning()
        end

        if self.State == State.warning then
            self:checkLife()
            self:calcRotation()
            self:changeAnimation()
        end

        if self.State == State.danger then
            self:calcRotation()
            self:changeAnimation()
            -- lógica para huida, recuperación, etc.
                if not self.timerActive then
                    self:CreateHuntingTimer()
                    self:RestTimmer()
                    self.timerActive = true
                end
        end
    end)
end

function AnimalHunt:KillerTimers()
    if isTimer(self.huntingTimer) then
        killTimer(self.huntingTimer)
        self.huntingTimer = nil
    end
    if isTimer(self.timer) then
        killTimer(self.timer)
        self.timer = nil
    end
    if isTimer(self.timerFor) then
        killTimer(self.timerFor)
        self.timerFor = nil
    end
end

function AnimalHunt:firstWarning()
  
    if isElement(self.blip) then
        destroyElement(self.blip)
        self.blip = nil -- Buena práctica para limpiar la referencia
    end
    self:calcRotation()

    if not self:checkLife() then
        self:changeAnimation()
        self:calcRotation()
    end

    if isElement(self.marker) then
        destroyElement(self.marker)
        self.marker = nil -- Buena práctica para limpiar la referencia
    end
end

--funciones timmer

function AnimalHunt:CreateHuntingTimer()

    self.huntingTimer = setTimer(function()
        outputChatBox("El ped ah desaparecido, ")
        destroyElement(self.ped)
      
    end, 180000, 1)
end

function AnimalHunt:RestTimmer()
    self.timer = setTimer(function()
        outputChatBox("comenzo el tiempo de descanzo")
        self:AnimalRecovery()

        setTimer(function()
            outputChatBox("Paso ya paso 10 segundos")
            self:checkLife()
            self:changeAnimation()
            
        end, 10000, 1)
    end, 60000, 1)
end

function AnimalHunt:CreateAndSetTimmer()
    self.timer = setTimer(function()
        destroyElement(self.marker)
        destroyElement(self.blip)
        killTimer(self.timer)
    end, 300000, 1)
    setElementData(self.ped, "deleteTimer", self.timer)
end
--funciones timmer 

function AnimalHunt:calcRotation()
    local x1, y1 = getElementPosition(self.ped)



    -- Asegurate de que `posiciones` esté definido globalmente
    local indiceAleatorio = math.random(1, #posiciones)
    local x2, y2 = unpack(posiciones[indiceAleatorio])

    local angulo = math.deg(math.atan2(x2 - x1, y2 - y1))
    local rotacion = (angulo + 180) % 360

    setElementRotation(self.ped, 0, 0, rotacion)
end

function AnimalHunt:AnimalRecovery()
      self.timerFor =  setTimer(function ()
                        local vida = getElementHealth(self.ped)
                        setElementHealth(self.ped, vida + 10)
                        end,2000,5)
        
end
