local guiEnabled = false
local myIdentity = {}
local myIdentifiers = {}
local hasIdentity = false
local isDead = false

ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_irpidentity:identityCheck')
AddEventHandler('esx_irpidentity:identityCheck', function(identityCheck)
	hasIdentity = identityCheck
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
	isDead = false
end)

RegisterNUICallback('escape', function(data, cb)
		EnableGui(false)
end)

function EnableGui(state)
	SetNuiFocus(state, state)
	guiEnabled = state

	SendNUIMessage({
		type = "enableui",
		enable = state
	})
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if guiEnabled then
			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 30,  true) -- MoveLeftRight
			DisableControlAction(0, 31,  true) -- MoveUpDown
			DisableControlAction(0, 21,  true) -- disable sprint
			DisableControlAction(0, 24,  true) -- disable attack
			DisableControlAction(0, 25,  true) -- disable aim
			DisableControlAction(0, 47,  true) -- disable weapon
			DisableControlAction(0, 58,  true) -- disable weapon
			DisableControlAction(0, 263, true) -- disable melee
			DisableControlAction(0, 264, true) -- disable melee
			DisableControlAction(0, 257, true) -- disable melee
			DisableControlAction(0, 140, true) -- disable melee
			DisableControlAction(0, 141, true) -- disable melee
			DisableControlAction(0, 143, true) -- disable melee
			DisableControlAction(0, 75,  true) -- disable exit vehicle
			DisableControlAction(27, 75, true) -- disable exit vehicle
			DisableControlAction(0, 245, true)
			DisableControlAction(0, 309, true)
			DisableControlAction(0, 246, true) -- disable y key
		end
	end
end)

---------------------------------------------------------------------------------------------------
----------------------------------VERY IMPORTANT FOR FUNCTIONALITY---------------------------------
---------------------------------------------------------------------------------------------------

RegisterNetEvent('updateIdentity')
AddEventHandler('updateIdentity', function(source, skin)
	Citizen.Wait(1000)
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
		TriggerServerEvent('setJob', setJob)
		TriggerServerEvent('setCash', setCash)
	end)
end)

---------------------------------------------------------------------------------------------------
----------------------------------VERY IMPORTANT FOR FUNCTIONALITY---------------------------------
---------------------------------------------------------------------------------------------------
	Citizen.CreateThread(function() 
		while true do
			Citizen.Wait(10)
				TriggerServerEvent('esx_irpidentity:getCharacterInformation')
		end	
	end)	
---------------------------------------------------------------------------------------------------
----------------------------------VERY IMPORTANT FOR FUNCTIONALITY---------------------------------
---------------------------------------------------------------------------------------------------

RegisterNetEvent('esx_irpidentity:setCharacterInformation')
AddEventHandler('esx_irpidentity:setCharacterInformation', function(firstname1, lastname1, job1, money1, bank1  ,firstname2, lastname2, job2, money2, bank2,firstname3, lastname3, job3, money3, bank3)	
xPlayer = ESX.GetPlayerData(source)
print(xPlayer)
if xPlayer ~= nil then
	SendNUIMessage({
		firstname1 = firstname1,
		lastname1 = lastname1,
		job1 = job1,
		money1 = money1,
		bank1 = bank1,
		firstname2 = firstname2,
		lastname2 = lastname2,
		job2 = job2,
		money2 = money2,
		bank2 = bank2,
		firstname3 = firstname3,
		lastname3 = lastname3,
		job3 = job3,
		money3 = money3,
		bank3 = bank3
		})
	end
	TriggerEvent('esx_irpidentity:showCharacterSelection')
end)

RegisterNetEvent('esx_irpidentity:showCharacterSelection')
	AddEventHandler('esx_irpidentity:showCharacterSelection', function()
		if not isDead then
			EnableGui(true)
		end
end)

RegisterNUICallback("CharacterChosen", function(data, cb)
   -- SetNuiFocus(false,false)
    --DoScreenFadeOut(500)
    TriggerServerEvent('esx_irpidentity:CharacterChosen', data.charid)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    cb("ok")
end)

RegisterNetEvent('esx_irpidentity:showRegisterIdentity')
AddEventHandler('esx_irpidentity:showRegisterIdentity', function()
	if not isDead then
		EnableGui(true)
	end
end)

RegisterNetEvent('esx_irpidentity:saveID')
AddEventHandler('esx_irpidentity:saveID', function(data)
	myIdentifiers = data
end)

RegisterNUICallback('register', function(data, cb)
	local reason = ""
	myIdentity = data
	for theData, value in pairs(myIdentity) do
		if theData == "firstname" or theData == "lastname" then
			reason = verifyName(value)
			
			if reason ~= "" then
				break
			end
		elseif theData == "dateofbirth" then
			if value == "invalid" then
				reason = "Invalid date of birth!"
				break
			end
		elseif theData == "height" then
			local height = tonumber(value)
			if height then
				if height > 200 or height < 140 then
					reason = "Unacceptable player height!"
					break
				end
			else
				reason = "Unacceptable player height!"
				break
			end
		end
	end
	
	if reason == "" then
		TriggerServerEvent('esx_irpidentity:setIdentity', data, myIdentifiers)
		EnableGui(false)
		Citizen.Wait(5000)
		TriggerEvent('esx_skin:openSaveableMenu', myIdentifiers.id)
	else
		ESX.ShowNotification(reason)
	end
end)
function verifyName(name)
	-- Don't allow short user names
	local nameLength = string.len(name)
	if nameLength > 25 or nameLength < 2 then
		return 'Your player name is either too short or too long.'
	end
	
	-- Don't allow special characters (doesn't always work)
	local count = 0
	for i in name:gmatch('[abcdefghijklmnopqrstuvwxyz���ABCDEFGHIJKLMNOPQRSTUVWXYZ���0123456789 -]') do
		count = count + 1
	end
	if count ~= nameLength then
		return 'Your player name contains special characters that are not allowed on this server.'
	end
	local spacesInName    = 0
	local spacesWithUpper = 0
	for word in string.gmatch(name, '%S+') do

		if string.match(word, '%u') then
			spacesWithUpper = spacesWithUpper + 1
		end

		spacesInName = spacesInName + 1
	end

	if spacesInName > 2 then
		return 'Your name contains more than two spaces'
	end
	
	if spacesWithUpper ~= spacesInName then
		return 'your name must start with a capital letter.'
	end

	return ''
end
-------------------------------------------------------------------------------------------------Updated 11/23/2019-----------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------Updated 11/23/2019-----------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------Updated 11/23/2019-----------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------Updated 11/23/2019-----------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------Updated 11/23/2019-----------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------Updated 11/23/2019-----------------------------------------------------------------------------------------------
local store = ""
local irpblip = nil
ESX = nil

local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

function drawTxt(x,y, width, height, scale, text, r,g,b,a, outline)
	SetTextFont(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropshadow(0, 0, 0, 0,255)
	SetTextDropShadow()
	if outline then SetTextOutline() end

	BeginTextCommandDisplayText('STRING')
	AddTextComponentSubstringPlayerName(text)
	EndTextCommandDisplayText(x - width/2, y - height/2 + 0.005)
end

RegisterNetEvent('esx_irpidentity:setBlip')
AddEventHandler('esx_irpidentity:setBlip', function(position)
	irpblip = AddBlipForCoord(position.x, position.y, position.z)

	SetBlipSprite(irpblip, 161)
	SetBlipScale(irpblip, 2.0)
	SetBlipColour(irpblip, 3)

	PulseBlip(irpblip)
end)

Citizen.CreateThread(function()
	for k,v in pairs(Stores) do
		local blip = AddBlipForCoord(v.position.x, v.position.y, v.position.z)
		SetBlipSprite(blip, 156)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(_U('medical_center'))
		EndTextCommandSetBlipName(blip)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local playerPos = GetEntityCoords(PlayerPedId(), true)

		for k,v in pairs(Stores) do
			local storePos = v.position
			local distance = Vdist(playerPos.x, playerPos.y, playerPos.z, storePos.x, storePos.y, storePos.z)

			if distance < Config.Marker.DrawDistance then
				if not holdingUp then
					DrawMarker(Config.Marker.Type, storePos.x, storePos.y, storePos.z - 1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.x, Config.Marker.y, Config.Marker.z, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a, false, false, 2, false, false, false, false)

					if distance < 1.7 then
						ESX.ShowHelpNotification(_U('press_to_switch', v.nameOfLocation))

						if IsControlJustReleased(0, Keys['E']) then
								TriggerServerEvent('esx_irpidentity:getClientInfo')
						end
					end
				end
			end
		end
	end
end)
