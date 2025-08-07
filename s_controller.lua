local posiciones = {
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


function inicio(typeAnimal)
    math.randomseed(os.time())

    local animal = AnimalHunt:create()
    local indiceAleatorio = math.random(1, #posiciones)
        
        local x1, y1, z1, __ = unpack(posiciones[indiceAleatorio])
        local radio = 30.0
      
    
    animal:SpawnPed(x1, y1, z1, typeAnimal)
    animal:CreateMarker(x1, y1, z1, radio)
    animal:CreateBlip(x1, y1, z1)
end

addEvent("createAnimalObj", true)
addEventHandler("createAnimalObj", root, function(typeAnimal)
       
    inicio(typeAnimal)
    
end)
