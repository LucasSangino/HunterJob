AnimalHunt = {}
AnimalHunt.__index = AnimalHunt

State = {peace=1, warning=2, danger=3}

function AnimalHunt:create()
    local self = setmetatable({}, AnimalHunt)

    self.ped = nil
    self.blip = nil
    self.marker = nil
    self.Accion = { "walk_civi", "RUN_civi", "SPRINT_civi" }
    self.State = State.peace

    return self
end

function AnimalHunt:startTimer()
    self.timer = setTimer(function()
        triggerEvent("onAnimalHuntExpired", resourceRoot, self)
        self:destroy()
    end, 5000, 1)
end

function AnimalHunt:destroy()
    if isElement(self.ped) then destroyElement(self.ped) end
    if isElement(self.blip) then destroyElement(self.blip) end
    if isTimer(self.timer) then killTimer(self.timer) end
end

function AnimalHunt:SpawnPed(x, y, z, typeAnimal)
    self.ped = createPed(listIds[typeAnimal], x, y, z)
    setElementHealth(self.ped, 100)
end

function AnimalHunt:CreateMarker(x, y, z, radio)
    self.marker = createMarker(x, y, z, "cylinder", radio, 255, 162, 51, 0)
    attachElements(self.marker, self.ped, 0, 0, 0)
    setElementData(self.marker, "animalHunt", self)
end 

function AnimalHunt:CreateBlip(x, y, z)
    self.blip = createBlip(x, y, z)
    setBlipColor(self.blip, 0, 255, 0, 255)
    setBlipSize(self.blip, 2)
end

function AnimalHunt:CreateAndSetTimmer()
    self.timer = setTimer(function()
        destroyElement(self.marker)
        destroyElement(self.blip)
        killTimer(self.timer)
    end, 300000, 1)
    setElementData(self.ped, "deleteTimer", self.timer)
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
    
end

function AnimalHunt:checkLife()
    local vida = getElementHealth(self.ped)
    if vida then
        if vida <= 70 then
            self.State = State.warning
            return true   
        end
        if vida <= 40 then
            self.State = State.danger
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
        givePlayerMoney(source, cause)
        destroyElement(money)
    end)
end

function AnimalHunt:EntroEnArea()
    addEventHandler("onMarkerHit", self.marker, function(hitElement)
        if getElementType(hitElement) == "player" then
            triggerEvent("onAnimalHuntMarkerHit", resourceRoot, self, hitElement)
            self:firstWarning()
        end
    end)
end

function AnimalHunt:RecibeDanoElPed()
    addEventHandler("onPedDamage", self.ped, function()
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
        end

    end)
end

function AnimalHunt:firstWarning()
    destroyElement(self.blip)
    self:calcRotation()

    if not self:checkLife() then
        self:changeAnimation()
        self:calcRotation()
    end

    destroyElement(self.marker)
end

function AnimalHunt:CreateHuntingTimer()
    self.huntingTimer = setTimer(function()
        self:deletePed()
    end, 300000, 1)
end

function AnimalHunt:calcRotation()
    local x1, y1 = getElementPosition(self.ped)

    -- Asegurate de que `posiciones` esté definido globalmente
    local indiceAleatorio = math.random(1, #posiciones)
    local x2, y2 = unpack(posiciones[indiceAleatorio])

    local angulo = math.deg(math.atan2(x2 - x1, y2 - y1))
    local rotacion = (angulo + 180) % 360

    setElementRotation(self.ped, 0, 0, rotacion)
end
