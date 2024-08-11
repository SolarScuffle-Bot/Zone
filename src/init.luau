local Players = game:GetService 'Players'

local Module = {}

local function newZone()
	local zone = {}
	zone.playerEntered = nil :: (Player) -> ()?
	zone.playerExited = nil :: (Player) -> ()?
	zone.inside = {} :: { [Player]: true }
	return zone
end

function Module.fromParts(parts: { BasePart })
	local zone = newZone()

	zone.pivots = table.create(#parts)
	zone.sizes = table.create(#parts)
	for i, part in parts do
		zone.pivots[i] = part:GetPivot()
		zone.sizes[i] = part.Size
	end

	return zone
end

function Module.fromPivot(pivot: CFrame, size: Vector3)
	local zone = newZone()

	zone.pivots = { pivot }
	zone.sizes = { size }

	return zone
end

export type Zone = typeof(Module.fromParts(...))

function Module.updatePlayers(zone: Zone, overlapParams: OverlapParams?)
	local newModelsInside = {}
	for i, pivot in zone.pivots do
		local size = zone.sizes[i]
		local parts = workspace:GetPartBoundsInBox(pivot, size, overlapParams)
		for _, part in parts do
			local model = part:FindFirstAncestorWhichIsA 'Model'
			if model then
				newModelsInside[model] = true
			end
		end
	end

	local nowInside = {}
	for model in newModelsInside do
		local player = Players:GetPlayerFromCharacter(model)
		if player then
			nowInside[player] = true
		end
	end

	local wasInside = zone.inside

	local playerEntered = zone.playerEntered
	if playerEntered then
		for player in nowInside do
			if not wasInside[player] then
				playerEntered(player)
			end
		end
	end

	local playerExited = zone.playerExited
	if playerExited then
		for player in wasInside do
			if not nowInside[player] then
				playerExited(player)
			end
		end
	end

	zone.inside = nowInside
end

return Module