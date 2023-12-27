local Bot = game.ReplicatedStorage.Interaction.BotGame

local IGC = workspace:WaitForChild("InGameClones")

local RS = game:GetService("ReplicatedStorage")
local SS = game:GetService("ServerScriptService")
local Interaction = RS:WaitForChild("Interaction")
local Inform = Interaction:WaitForChild("Information")
local UA = Interaction:WaitForChild("YouAlr")

local Tr = RS:WaitForChild("Transition")
local WDummy = Tr:WaitForChild("WhiteDummy")
local BDummy = Tr:WaitForChild("BlackDummy")

--Boards and Sets
local SetBoard = RS:WaitForChild("Set")
local MirBoard = RS:WaitForChild("Mirrored")
local TenBoard = RS:WaitForChild("Ten")
local Turk = RS:WaitForChild("Turkish")
local PM = RS:WaitForChild("PM")

local Hi = 1.397
local sets = {workspace.Set1, workspace.Set2, workspace.Set3, workspace.Set4, workspace.Set5, workspace.Set6, workspace.Set7, workspace.Set8, workspace.Set9, workspace.Set10, workspace.Set11, workspace.Set12, workspace.Set13, workspace.Set14,workspace.Set15,workspace.Set16,workspace.Set17,workspace.Set18,workspace.Set19,workspace.Set20}
local TS = game:GetService("TweenService")

local getLegal = require(game.ServerStorage:WaitForChild("Modules"):WaitForChild("getLegal"))

local Int = RS:WaitForChild("Interaction")

--Managing Accessories
local toggles = {
	["All"] = true,
	["Accessory"] = true,
	["Hat"] = true,
	["BodyBackAttachment"] = true, --Removing BodyBackAttachments which tend to be of the Back Accessory type.
	["BodyFrontAttachment"] = true,
	["FaceFrontAttachment"] = true,
	["HairAttachment"] = true,
	["HatAttachment"] = true,
	["LeftCollarAttachment"] = true,
	["NeckAttachment"] = true,
	["RightCollarAttachment"] = true,
	["WaistCenterAttachment"] = false,
	["WaistFrontAttachment"] = false
}

local going = {}
local streak = {}

local oddTable = {4, 5, 12, 13, 20, 21, 28, 29}
local Right = {4, 12, 20, 28}
local Left = {5, 13, 21, 29}

local WER = {6, 7, 8, 14, 15, 16, 22, 23, 24, 30, 31, 32}
local BER = {27, 26, 25, 19, 18, 17, 11, 10, 9, 3, 2, 1}

--King Rows
local WKR = {1,2,3,4}
local BKR = {29,30,31,32}

local tab = {}

local round = {}

local function MovingS(original, newplace, SMod, Place)
	SMod.move(original, newplace, Place)
end

local function CaptureS(original, newplace, Set, SMod, Place, Sound, Multiplie)
	SMod.capture(original, newplace, going[Set], streak[Set], Place, Sound, Multiplie)
end

function CloneMe(char)
	char.Archivable = true
	local clone = char:Clone()
	for _, v in pairs(clone:GetChildren()) do
		if v:IsA("Part") or v:IsA("MeshPart") then
			v.Anchored = true
		end
		if v:IsA("Accessory") then
			v.Handle.Anchored = true

		end
		if v:IsA("Hat") then
			v.Handle.Anchored = true
		end
	end
	for _, v in pairs(char:GetChildren()) do

		if v:IsA("Script") or v:IsA("LocalScript") then
			v:Destroy()
		end
	end
	char.Archivable = false

	return clone
end

function removewaist(char)
	local Hum = char:WaitForChild("Humanoid")
	local accessories = Hum:GetAccessories()
	if (#accessories > 0) then

		for i, v in pairs(accessories) do
			local accessory = char:FindFirstChild(tostring(v))
			if v:IsA("Accessory") then
				local attachment = v.Handle:FindFirstChildWhichIsA("Attachment")
				if toggles[tostring(attachment)] == false then
					accessory:Destroy()
				end
			end
		end
	end
end

function resetcoloredtiles(board)
	for _,v in pairs(board.Numbers:GetChildren()) do
		if v.Name ~= "Base" then
			v.Color = Color3.fromRGB(17,17,17)
			v.Direction.Value = ""
		end
	end
end

function space(Set)
	local config = Set:WaitForChild("Config")
	local WA = config:WaitForChild("WhiteAmount")
	local BA = config:WaitForChild("BlackAmount")
	local Turn = config:WaitForChild("Turn")
	local Exist = Set:WaitForChild("PlayerExists") -- !!! (bot) idk
	local store = require(Set.Store)
	local Resolution = require(Set.Results)
	local WP = config:WaitForChild("WhitePlayer")
	local BP = config:WaitForChild("BlackPlayer")
	local WPlayer = game.Players:GetPlayerFromCharacter(WP.Value)
	local BPlayer = game.Players:GetPlayerFromCharacter(BP.Value)
	local Custom = config:WaitForChild("Custom")
	local nation = config:WaitForChild("Nation")
	local List = Set:WaitForChild("List")
	local Real = Set.Parent

	local Win = Int:WaitForChild("Win")
	local Lose = Int:WaitForChild("Lose")

	if WA.Value ~= 0 and BA.Value ~= 0 then
		if Turn.Value == true then
			local cannotmove = {}
			for _,v in pairs(Set:GetChildren()) do
				if v.Name == "White" then
					if v.Piece.Captured.Value == true or v.Piece.CanMove.Value == false then
						table.insert(cannotmove, v)
					end

				end
			end
			if #cannotmove == 12 then
				Exist.Disabled = true
				local obtain = store.gettable()
				table.insert(obtain, "\nBlack wins")
				local final = table.concat(obtain)
				pcall(function()
					--webhook:createMessage(final)
				end)

				wait(0.1)
				Resolution.game(BPlayer, WPlayer, Custom.Value, nation.Value)
				local CList = List:Clone()
				--CList.Parent = WPlayer.PlayerGui.ScreenGui.Record.Records.Frame
				local BList = List:Clone()
				--BList.Parent = BPlayer.PlayerGui.ScreenGui.Record.Records.Frame
				Win:FireClient(BPlayer)
				if Custom.Value == false then
					BPlayer.leaderstats.Wins.Value = BPlayer.leaderstats.Wins.Value + 1
				end
				wait()
				Lose:FireClient(WPlayer)
				local name1 = WPlayer.Name
				local name2 = BPlayer.Name
				wait(3)
				local ResetModule = require(SS.ResetCharacter)
				task.delay(0, function()
					if game.Players:FindFirstChild(name1) then
						ResetModule.ingamereset(WPlayer)
					end
				end)
				task.delay(0, function()
					if game.Players:FindFirstChild(name2) then
						ResetModule.ingamereset(BPlayer)
					end
				end)
				--OList.Parent = offer.PlayerGui.ScreenGui.Record.Records.Frame
				wait(2)
				Real.Occupied.Value = false
				Set:Destroy()
			end
		else
			local cannotmove = {}
			for _,v in pairs(Set:GetChildren()) do
				if v.Name == "Black" then
					if v.Piece.Captured.Value == true or v.Piece.CanMove.Value == false then
						table.insert(cannotmove, v)
					end
				end
			end
			if #cannotmove == 12 then
				Exist.Disabled = true
				local obtain = store.gettable()
				table.insert(obtain, "\nWhite wins")
				local final = table.concat(obtain)
				pcall(function()
					--webhook:createMessage(final)
				end)

				wait(0.1)
				Resolution.game(WPlayer, BPlayer, Custom.Value, nation.Value)
				local CList = List:Clone()
				--CList.Parent = WPlayer.PlayerGui.ScreenGui.Record.Records.Frame
				local BList = List:Clone()
				--BList.Parent = BPlayer.PlayerGui.ScreenGui.Record.Records.Frame
				Win:FireClient(WPlayer)
				if Custom.Value == false then
					WPlayer.leaderstats.Wins.Value = WPlayer.leaderstats.Wins.Value + 1
				end
				wait()
				local name1 = WPlayer.Name
				local name2 = BPlayer.Name
				wait(3)
				local ResetModule = require(SS.ResetCharacter)
				task.delay(0, function()
					if game.Players:FindFirstChild(name1) then
						ResetModule.ingamereset(WPlayer)
					end
				end)
				task.delay(0, function()
					if game.Players:FindFirstChild(name2) then
						ResetModule.ingamereset(BPlayer)
					end
				end)
				--OList.Parent = offer.PlayerGui.ScreenGui.Record.Records.Frame
				wait(2)
				Real.Occupied.Value = false
				Set:Destroy()
			end
		end
	end
end

function LegalMoves(Set)
	local config = Set:WaitForChild("Config")
	local RP = config:WaitForChild("RPromote")
	local Draw = config:WaitForChild("Draw")

	task.delay(0, function()
		for _,v in pairs(Set:GetChildren()) do
			if v.Name == "White" then
				if v.Piece.Captured.Value == false then


					v.Piece.Script.Disabled = false

					v.Piece.Silly.Disabled = false
					if v.Piece.King.Value == true then
						v.Piece.KingWMC.Disabled = false
					else
						v.Piece.WMC.Disabled = false
					end
				end
				if not table.find(oddTable, v.Piece.Value.Value) then
					if not table.find(WER, v.Piece.Value.Value) then
						v.Piece.UpLeft.Value = v.Piece.Value.Value + 5
						v.Piece.UpRight.Value = v.Piece.Value.Value + 4
						v.Piece.BackLeft.Value = v.Piece.Value.Value - 3
						v.Piece.BackRight.Value = v.Piece.Value.Value - 4
					else 
						v.Piece.UpLeft.Value = v.Piece.Value.Value + 4
						v.Piece.UpRight.Value = v.Piece.Value.Value + 3
						v.Piece.BackLeft.Value = v.Piece.Value.Value - 4
						v.Piece.BackRight.Value = v.Piece.Value.Value - 5
					end
					local s = v.Piece.UpLeft.Value or v.Piece.UpRight.Value
					if s > 32 then
						s = 0
						if v.Piece.King.Value == false and v.Piece.Captured.Value == false then
							if RP.Value == false then
								v.Piece.King.Value = true
								v.Piece.Decal.Transparency = 0
								v.Piece.WMC.Disabled = true
								v.Piece.KingWMC.Disabled = false
								Draw.Value = -1
							end
						end
					end
					local t = v.Piece.BackLeft.Value or v.Piece.BackRight.Value
					if t < 1 then
						t = 0
					end
				else if table.find(Right, v.Piece.Value.Value) then
						v.Piece.BackRight.Value = v.Piece.Value.Value - 4
						v.Piece.UpRight.Value = v.Piece.Value.Value + 4
						v.Piece.UpLeft.Value = 0
						v.Piece.BackLeft.Value = 0
						if v.Piece.UpRight.Value > 32 then 
							v.Piece.UpRight.Value = 0
							if v.Piece.King.Value == false and v.Piece.Captured.Value == false then
								if RP.Value == false then
									v.Piece.King.Value = true
									v.Piece.Decal.Transparency = 0
									v.Piece.WMC.Disabled = true
									v.Piece.KingWMC.Disabled = false
									Draw.Value = -1
								end
							end
						end
					elseif table.find(Left, v.Piece.Value.Value) then
						v.Piece.BackLeft.Value = v.Piece.Value.Value - 4
						v.Piece.UpLeft.Value = v.Piece.Value.Value + 4
						v.Piece.UpRight.Value = 0
						v.Piece.BackRight.Value = 0
						if v.Piece.UpLeft.Value > 32 then 
							v.Piece.UpLeft.Value = 0
							if v.Piece.King.Value == false and v.Piece.Captured.Value == false then
								if RP.Value == false then
									v.Piece.King.Value = true
									v.Piece.Decal.Transparency = 0
									v.Piece.WMC.Disabled = true
									v.Piece.KingWMC.Disabled = false
									Draw.Value = -1
								end
							end
						end
					end
				end
				v.Piece.CaptureFound.Value = false
			end
			if v.Name == "Black" then
				if v.Piece.Captured.Value == false then

					v.Piece.Script.Disabled = false
					v.Piece.Silly.Disabled = false
					if v.Piece.King.Value == true then
						v.Piece.KingBMC.Disabled = false
					else
						v.Piece.BMC.Disabled = false
					end
				end
				if not table.find(oddTable, v.Piece.Value.Value) then
					if not table.find(BER, v.Piece.Value.Value) then
						v.Piece.DownLeft.Value = v.Piece.Value.Value - 5
						v.Piece.DownRight.Value = v.Piece.Value.Value - 4
						v.Piece.BackLeft.Value = v.Piece.Value.Value + 3
						v.Piece.BackRight.Value = v.Piece.Value.Value + 4
					else
						v.Piece.DownLeft.Value = v.Piece.Value.Value - 4
						v.Piece.DownRight.Value = v.Piece.Value.Value - 3
						v.Piece.BackLeft.Value = v.Piece.Value.Value + 4
						v.Piece.BackRight.Value = v.Piece.Value.Value + 5
					end
					local s = v.Piece.DownLeft.Value or v.Piece.DownRight.Value
					if s < 1 then
						s = 0
						if v.Piece.King.Value == false and v.Piece.Captured.Value == false then
							if RP.Value == false then
								v.Piece.King.Value = true
								v.Piece.Decal.Transparency = 0
								v.Piece.BMC.Disabled = true
								v.Piece.KingBMC.Disabled = false
								Draw.Value = -1
							end
						end
					end
					local t = v.Piece.BackLeft.Value or v.Piece.BackRight.Value
					if t > 32 then
						t = 0
					end
				else if table.find(Left, v.Piece.Value.Value) then
						v.Piece.DownRight.Value = v.Piece.Value.Value - 4
						v.Piece.BackRight.Value = v.Piece.Value.Value + 4
						v.Piece.BackLeft.Value = 0
						v.Piece.DownLeft.Value = 0
						if v.Piece.DownRight.Value < 1 then 
							v.Piece.DownRight.Value = 0
							if v.Piece.King.Value == false and v.Piece.Captured.Value == false then
								if RP.Value == false then
									v.Piece.King.Value = true
									v.Piece.Decal.Transparency = 0
									v.Piece.BMC.Disabled = true
									v.Piece.KingBMC.Disabled = false
									Draw.Value = -1
								end
							end
						end
					elseif table.find(Right, v.Piece.Value.Value) then
						v.Piece.BackLeft.Value = v.Piece.Value.Value + 4
						v.Piece.DownLeft.Value = v.Piece.Value.Value - 4
						v.Piece.BackRight.Value = 0
						v.Piece.DownRight.Value = 0
						if v.Piece.DownLeft.Value < 1 then 
							v.Piece.DownLeft.Value = 0
							if v.Piece.King.Value == false and v.Piece.Captured.Value == false then
								if RP.Value == false then
									v.Piece.King.Value = true
									v.Piece.Decal.Transparency = 0
									v.Piece.BMC.Disabled = true
									v.Piece.KingBMC.Disabled = false
									Draw.Value = -1
								end
							end
						end
					end
				end
				v.Piece.CaptureFound.Value = false
			end

		end
	end)
end

function transfer(str, List)
	local text = Instance.new("TextLabel")
	text.Parent = List
	text.BackgroundTransparency = 1
	text.TextScaled = true
	text.TextWrapped = true
	text.TextColor3 = Color3.fromRGB(0,0,0)
	text.Font = Enum.Font.SourceSans
	text.Text = str
end

local function tileClick(Set, botplaying, bot)--, movetotile, selectedtile, color, capverify, selectedpiece, killed, Set)
	if Set then
		local botPieces = {}
		local botMoves = {}
		local botCaptures = {}
		local pieces = {}
		local piecesc = {}

		local board = Set:WaitForChild("board")
		local config = Set:WaitForChild("Config")

		local WA = config:WaitForChild("WhiteAmount")
		local BA = config:WaitForChild("BlackAmount")

		local RK = config:WaitForChild("FlyingKing")

		for i, v in Set:GetChildren() do
			if v.Name == botplaying then
				table.insert(botPieces, v)
			end
		end

		for i1, piece in botPieces do
			task.wait(0.1)
			local d = getLegal.getLegalMoves(bot, piece.Piece)
			local k = getLegal.getLegalCaptures(bot, piece.Piece)

			if d[1] then
				botMoves[piece] = {}
				for i, v in d do
					table.insert(pieces, v)
					table.insert(botMoves[piece], v)
				end
			end
			if k[1] then
				botCaptures[piece] = {}
				for i, v in k do
					table.insert(piecesc, v)
					table.insert(botCaptures[piece], v)
				end
			end
		end
		resetcoloredtiles(board)
		print(#botMoves, #botCaptures)
		if #piecesc == 0 then
			if #pieces > 0 then
				for piece, v in botMoves do
					movePiece(piece.Piece, board.Numbers[tostring(v[math.random(1, #v)])], false, Set)
					break
				end
			else
				-- end game
			end
		else
			for piece, v in botCaptures do
				capturePiece(piece.Piece, false, board.Numbers[tostring(v[math.random(1, #v)])], Set, WA, BA, RK, botplaying, bot)
				break
			end
		end
	end

end

function capturePiece(selected, turn, tile, Set, IR, botplaying, bot)

	local config = Set:WaitForChild("Config")
	local Moves = config:WaitForChild("Moves")
	local Draw = config:WaitForChild("Draw")
	local Jumper = config:WaitForChild("Jumper")
	local BA = config:WaitForChild("BlackAmount")
	local WA = config:WaitForChild("WhiteAmount")
	local IJ = config:WaitForChild("InitialJump")
	local Turn = config:WaitForChild("Turn")
	local RP = config:WaitForChild("RPromote")
	local RK = config:WaitForChild("FlyingKing")
	local BlackJump = config:WaitForChild("BlackJump")
	local WhiteJump = config:WaitForChild("WhiteJump")

	local List = Set:WaitForChild("List")

	local store = require(Set.Store)
	local SMod = require(Set.Sound)
	local Captures = require(Set:WaitForChild("Captures"))

	local board = Set:WaitForChild("board")

	local Place = Set:WaitForChild("Higher"):WaitForChild("Place")
	local Sound = Set:WaitForChild("Higher"):WaitForChild("One")
	local Multiple = Set:WaitForChild("Higher"):WaitForChild("Multiple")

	--if threading ~= nil then
	--	task.cancel(threading)
	--end
	if not round[Set] then round[Set] = 1 end
	if not going[Set] then going[Set] = false end
	if not streak[Set] then streak[Set] = 0 end

	local threading = task.delay(0, function() -- nonlocal
		if selected.CaptureOnLeft.Value ~= nil then
			if (tile.Name == tostring(selected.CaptureOnLeft.Value.BackRight.Value) and (selected.King.Value == false or RK.Value == false)) or (turn == true and tile.Direction.Value == "UL") or (turn == false and tile.Direction.Value == "DR") then
				board.Numbers[tostring(selected.Value.Value)].OccupiedBy.Value = ""
				board.Numbers[tostring(selected.CaptureOnLeft.Value.Value.Value)].OccupiedBy.Value = ""
				PM:FireAllClients(selected, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z), "C")
				selected.CaptureOnLeft.Value.Captured.Value = true
				local captured = selected.CaptureOnLeft.Value
				if IR.Value == false then
					captured.Position = Set.Holder.Position
				else
					Captures.captures(captured.Value.Value)
					print(#Captures.getnumbers())
					Captures.storepieces(captured)
				end
				selected.CaptureOnLeft.Value.Value.Value = 0
				for _,v in pairs(selected.CaptureOnLeft.Value:GetChildren()) do
					if v.ClassName == "Script" then
						v.Disabled = true
					end
				end
				local previous = selected.King.Value
				selected.Direction.Value = "L"

				selected.CaptureOnLeft.Value = nil
				selected.CaptureOnRight.Value = nil
				selected.COBL.Value = nil
				selected.COBR.Value = nil

				Moves.Value = Moves.Value + 1
				Draw.Value = 0


				if turn == false then
					WA.Value = WA.Value - 1
				else
					BA.Value = BA.Value - 1
				end

				if Jumper.Value == nil then
					IJ.Value = selected.Value.Value
				end
				selected.Value.Value = tonumber(tile.Name)
				tile.OccupiedBy.Value = selected.Parent.Name
				Jumper.Value = selected
				local archive = selected
				selected = nil
				LegalMoves(Set)
				resetcoloredtiles(board)
				archive.State.Value = true
				wait(0.5)
				CaptureS(archive, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z), Set, SMod, Place, Sound, Multiple)
				wait(1)
				if Jumper.Value.CaptureFound.Value == true then
					going[Set] = true
					streak[Set] = streak[Set] + 1
					task.wait(1)
					tileClick(Set, botplaying, bot)
				else
					SMod.finalpos(archive, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z))
					for _, b in pairs(Captures.getpieces()) do
						b.Position = Set.Holder.Position
					end
					Captures.reset()
					archive.Direction.Value = ""
					print(IJ.Value .. "x" .. tile.Name)
					local new = IJ.Value .. "x" .. tile.Name
					transfer(new, List)

					Jumper.Value = nil

					if turn == false then
						if table.find(WKR, archive.Value.Value) then
							if RP.Value == true then
								archive.King.Value = true
								archive.Decal.Transparency = 0
								archive.BMC.Disabled = true
								archive.KingBMC.Disabled = false
							end
						end
						Turn.Value = true
						BlackJump.Value = false
						table.insert(tab, " " .. new .. "\n")
						round[Set] = round[Set] + 1 -- round[Set] + 1
						store.storetable(tab)
					elseif turn == true then
						if table.find(BKR, archive.Value.Value) then
							if RP.Value == true then
								archive.King.Value = true
								archive.Decal.Transparency = 0
								archive.WMC.Disabled = true
								archive.KingWMC.Disabled = false
							end
						end
						Turn.Value = false
						WhiteJump.Value = false
						table.insert(tab, round[Set] .. ". " .. new)
						store.storetable(tab)
					end
					IJ.Value = 0
					going[Set] = false
					wait(1)
					streak[Set] = 0
				end

			end

		end
		if selected ~= nil then 
			if selected.CaptureOnRight.Value ~= nil then 
				if (tile.Name == tostring(selected.CaptureOnRight.Value.BackLeft.Value) and (selected.King.Value == false or RK.Value == false)) or (turn == true and tile.Direction.Value == "UR") or (turn == false and tile.Direction.Value == "DL") then
					board.Numbers[tostring(selected.Value.Value)].OccupiedBy.Value = ""
					board.Numbers[tostring(selected.CaptureOnRight.Value.Value.Value)].OccupiedBy.Value = ""
					PM:FireAllClients(selected, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z), "C")
					selected.CaptureOnRight.Value.Captured.Value = true
					local captured = selected.CaptureOnRight.Value
					if IR.Value == false then
						captured.Position = Set.Holder.Position
					else
						Captures.captures(captured.Value.Value)
						print(#Captures.getnumbers())
						Captures.storepieces(captured)
					end
					selected.CaptureOnRight.Value.Value.Value = 0

					for _,v in pairs(selected.CaptureOnRight.Value:GetChildren()) do
						if v.ClassName == "Script" then
							v.Disabled = true
						end
					end
					local previous = selected.King.Value
					selected.Direction.Value = "R"


					selected.CaptureOnLeft.Value = nil
					selected.CaptureOnRight.Value = nil
					selected.COBL.Value = nil
					selected.COBR.Value = nil

					Moves.Value = Moves.Value + 1
					Draw.Value = 0

					if turn == false then
						WA.Value = WA.Value - 1
					else
						BA.Value = BA.Value - 1
					end




					if Jumper.Value == nil then
						IJ.Value = selected.Value.Value
					end
					selected.Value.Value = tonumber(tile.Name)
					tile.OccupiedBy.Value = selected.Parent.Name
					Jumper.Value = selected
					local archive = selected
					selected = nil
					LegalMoves(Set)
					resetcoloredtiles(board)
					archive.State.Value = true
					wait(0.5)
					CaptureS(archive, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z), Set, SMod, Place, Sound, Multiple)
					wait(1)
					if Jumper.Value.CaptureFound.Value == true then
						going[Set] = true
						streak[Set] = streak[Set] + 1
						tileClick(Set, botplaying, bot)
					else
						SMod.finalpos(archive, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z))
						for _, b in pairs(Captures.getpieces()) do
							b.Position = Set.Holder.Position
						end
						Captures.reset()
						archive.Direction.Value = ""
						print(IJ.Value .. "x" .. tile.Name)
						local new = IJ.Value .. "x" .. tile.Name
						transfer(new, List)
						Jumper.Value = nil
						if turn == false then
							if table.find(WKR, archive.Value.Value) then
								if RP.Value == true then
									archive.King.Value = true
									archive.Decal.Transparency = 0
									archive.BMC.Disabled = true
									archive.KingBMC.Disabled = false
								end
							end
							Turn.Value = true
							BlackJump.Value = false
							table.insert(tab, " " .. new .. "\n")
							round[Set] = round[Set] + 1
							store.storetable(tab)
						elseif turn == true then
							if table.find(BKR, archive.Value.Value) then
								if RP.Value == true then
									archive.King.Value = true
									archive.Decal.Transparency = 0
									archive.WMC.Disabled = true
									archive.KingWMC.Disabled = false
								end
							end
							Turn.Value = false
							WhiteJump.Value = false
							table.insert(tab, round[Set] .. ". " .. new)
							store.storetable(tab)
						end
						IJ.Value = 0
						going[Set] = false
						wait(1)
						streak[Set] = 0
					end

				end
			end
		end
		if selected ~= nil then
			if selected.COBL.Value ~= nil then
				if ((selected.COBL.Value:FindFirstChild("UpRight") and tile.Name == tostring(selected.COBL.Value.UpRight.Value)) or (selected.COBL.Value:FindFirstChild("DownRight") and tile.Name == tostring(selected.COBL.Value.DownRight.Value)) and (selected.King.Value == false or RK.Value == false)) or (turn == true and tile.Direction.Value == "DL") or (turn == false and tile.Direction.Value == "UR") then
					board.Numbers[tostring(selected.Value.Value)].OccupiedBy.Value = ""
					board.Numbers[tostring(selected.COBL.Value.Value.Value)].OccupiedBy.Value = ""
					PM:FireAllClients(selected, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z), "C")
					local captured = selected.COBL.Value
					if IR.Value == false then
						captured.Position = Set.Holder.Position
					else
						Captures.captures(captured.Value.Value)
						print(#Captures.getnumbers())
						Captures.storepieces(captured)
					end
					selected.COBL.Value.Value.Value = 0
					selected.COBL.Value.Captured.Value = true
					for _,v in pairs(selected.COBL.Value:GetChildren()) do
						if v.ClassName == "Script" then
							v.Disabled = true
						end
					end
					local previous = selected.King.Value
					selected.Direction.Value = "BL"

					selected.CaptureOnLeft.Value = nil
					selected.CaptureOnRight.Value = nil
					selected.COBL.Value = nil
					selected.COBR.Value = nil

					Moves.Value = Moves.Value + 1
					Draw.Value = 0


					if turn == false then
						WA.Value = WA.Value - 1
					else
						BA.Value = BA.Value - 1
					end


					if Jumper.Value == nil then
						IJ.Value = selected.Value.Value
					end
					selected.Value.Value = tonumber(tile.Name)
					tile.OccupiedBy.Value = selected.Parent.Name
					Jumper.Value = selected
					local archive = selected
					selected = nil
					LegalMoves(Set)
					resetcoloredtiles(board)
					archive.State.Value = true
					wait(0.5)
					CaptureS(archive, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z), Set, SMod, Place, Sound, Multiple)
					wait(1)
					if Jumper.Value.CaptureFound.Value == true then
						going[Set] = true
						streak[Set] = streak[Set] + 1
						tileClick(Set, botplaying, bot)
					else
						SMod.finalpos(archive, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z))
						for _, b in pairs(Captures.getpieces()) do
							b.Position = Set.Holder.Position
						end
						Captures.reset()
						archive.Direction.Value = ""
						print(IJ.Value .. "x" .. tile.Name)
						local new = IJ.Value .. "x" .. tile.Name
						transfer(new, List)
						Jumper.Value = nil
						if turn == false then
							if table.find(WKR, archive.Value.Value) then
								if RP.Value == true then
									archive.King.Value = true
									archive.Decal.Transparency = 0
									archive.BMC.Disabled = true
									archive.KingBMC.Disabled = false
								end
							end
							Turn.Value = true
							BlackJump.Value = false
							table.insert(tab, " " .. new .. "\n")
							round[Set] = round[Set] + 1
							store.storetable(tab)
						elseif turn == true then
							if table.find(BKR, archive.Value.Value) then
								if RP.Value == true then
									archive.King.Value = true
									archive.Decal.Transparency = 0
									archive.WMC.Disabled = true
									archive.KingWMC.Disabled = false
								end
							end
							Turn.Value = false
							WhiteJump.Value = false
							table.insert(tab, round[Set] .. ". " .. new)
							store.storetable(tab)
						end
						IJ.Value = 0
						going[Set] = false
						wait(1)
						streak[Set] = 0
					end

				end
			end
		end
		if selected ~= nil then 
			if selected.COBR.Value ~= nil then
				if ((selected.COBR.Value:FindFirstChild("UpLeft") and tile.Name == tostring(selected.COBR.Value.UpLeft.Value)) or (selected.COBR.Value:FindFirstChild("DownLeft") and tile.Name == tostring(selected.COBR.Value.DownLeft.Value)) and (selected.King.Value == false or RK.Value == false)) or (turn == true and tile.Direction.Value == "DR") or (turn == false and tile.Direction.Value == "UL") then
					board.Numbers[tostring(selected.Value.Value)].OccupiedBy.Value = ""
					board.Numbers[tostring(selected.COBR.Value.Value.Value)].OccupiedBy.Value = ""
					PM:FireAllClients(selected, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z), "C")
					local captured = selected.COBR.Value
					if IR.Value == false then
						captured.Position = Set.Holder.Position
					else
						Captures.captures(captured.Value.Value)
						print(#Captures.getnumbers())
						Captures.storepieces(captured)
					end
					selected.COBR.Value.Value.Value = 0
					selected.COBR.Value.Captured.Value = true
					for _,v in pairs(selected.COBR.Value:GetChildren()) do
						if v.ClassName == "Script" then
							v.Disabled = true
						end
					end
					selected.Direction.Value = "BR"
					local previous = selected.King.Value

					selected.CaptureOnLeft.Value = nil
					selected.CaptureOnRight.Value = nil
					selected.COBL.Value = nil
					selected.COBR.Value = nil

					Moves.Value = Moves.Value + 1
					Draw.Value = 0


					if turn == false then
						WA.Value = WA.Value - 1
					else
						BA.Value = BA.Value - 1
					end


					if Jumper.Value == nil then
						IJ.Value = selected.Value.Value
					end
					selected.Value.Value = tonumber(tile.Name)
					tile.OccupiedBy.Value = selected.Parent.Name
					Jumper.Value = selected
					local archive = selected
					selected = nil
					LegalMoves(Set)
					resetcoloredtiles(board)
					archive.State.Value = true
					wait(0.5)
					CaptureS(archive, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z), Set, SMod, Place, Sound, Multiple)
					wait(1)
					if Jumper.Value.CaptureFound.Value == true then
						going[Set] = true
						streak[Set] = streak[Set] + 1
						tileClick(Set, botplaying, bot)
					else
						SMod.finalpos(archive, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z))
						for _, b in pairs(Captures.getpieces()) do
							b.Position = Set.Holder.Position
						end
						Captures.reset()
						archive.Direction.Value = ""
						print(IJ.Value .. "x" .. tile.Name)
						local new = IJ.Value .. "x" .. tile.Name
						transfer(new, List)
						Jumper.Value = nil
						if turn == false then
							if table.find(WKR, archive.Value.Value) then
								if RP.Value == true then
									archive.King.Value = true
									archive.Decal.Transparency = 0
									archive.BMC.Disabled = true
									archive.KingBMC.Disabled = false
								end
							end
							Turn.Value = true
							BlackJump.Value = false
							table.insert(tab, " " .. new .. "\n")
							round[Set] = round[Set] + 1
							store.storetable(tab)
						elseif turn == true then
							if table.find(BKR, archive.Value.Value) then
								if RP.Value == true then
									archive.King.Value = true
									archive.Decal.Transparency = 0
									archive.WMC.Disabled = true
									archive.KingWMC.Disabled = false
								end
							end
							Turn.Value = false
							WhiteJump.Value = false
							table.insert(tab, round[Set] .. ". " .. new)
							store.storetable(tab)
						end
						IJ.Value = 0
						going[Set] = false
						wait(1)
						streak[Set] = 0

					end

				end
			end
		end
		space(Set)

	end)

end

function movePiece(selected, tile, t, Set)
	local config = Set:WaitForChild("Config")

	local board = Set:WaitForChild("board")

	local List = Set:WaitForChild("List")

	local Moves = config:WaitForChild("Moves")
	local Draw = config:WaitForChild("Draw")
	local RP = config:WaitForChild("RPromote")
	local Turn = config:WaitForChild("Turn")

	local store = require(Set.Store)
	local SMod = require(Set.Sound)

	local Place = Set:WaitForChild("Higher"):WaitForChild("Place")
	local Sound = Set:WaitForChild("Higher"):WaitForChild("One")
	local Multiple = Set:WaitForChild("Higher"):WaitForChild("Multiple")

	--if threading ~= nil then
	--	task.cancel(threading)
	--end
	if not round[Set] then round[Set] = 1 end
	local threading = task.delay(0, function()
		if tile.OccupiedBy.Value == "" then
			board.Numbers[tostring(selected.Value.Value)].OccupiedBy.Value = ""
			PM:FireAllClients(selected, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z), "M")

			local new = selected.Value.Value .. "-" .. tile.Name
			transfer(new, List)
			selected.Value.Value = tonumber(tile.Name)
			MovingS(selected, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z), SMod, Place)
			tile.OccupiedBy.Value = selected.Parent.Name
			local archive = selected
			selected = nil
			LegalMoves(Set)
			resetcoloredtiles(board)
			task.delay(0, function()
				archive.MoveCD.Value = true
				wait(0.5)
				archive.MoveCD.Value = false
			end)
			wait(0.3)
			Moves.Value = Moves.Value + 1
			Draw.Value = Draw.Value + 1
			if t == false then
				if table.find(WKR, archive.Value.Value) then
					if RP.Value == true then
						archive.King.Value = true
						archive.Decal.Transparency = 0
						archive.BMC.Disabled = true
						archive.KingBMC.Disabled = false
					end
				end
				Turn.Value = true
				table.insert(tab, " " .. new .. "\n")
				round[Set] = round[Set] + 1
				store.storetable(tab)
			else
				if table.find(BKR, archive.Value.Value) then
					if RP.Value == true then
						archive.King.Value = true
						archive.Decal.Transparency = 0
						archive.WMC.Disabled = true
						archive.KingWMC.Disabled = false
					end
				end
				Turn.Value = false
				table.insert(tab, round .. ". " .. new)
				store.storetable(tab)
			end

			MovingS(archive, Vector3.new(tile.Position.X, tile.Position.Y + Hi, tile.Position.Z), SMod, Place)
		end
		space(Set)
	end)
end

-- Bot game
local function botStart(req, bot, mode, mandjump, bw, fl, convert, imrem, maximum, restpromote, mir, size, turkish)
	if req.Character.Set.Value == 0 and req.Character.Spectate.Value == false then
		bot = bot:Clone()
		bot.Name = 'Bot'
		bot.Parent = workspace
		local random
		local Chosen = false
		for _,v in pairs(sets) do
			if v.Occupied.Value == false then
				random = v.GameNumber.Value
				break
			end
		end

		sets[random].Occupied.Value = true
		req.Character.Set.Value = random

		local sit = sets[random]:FindFirstChild("Set")
		if sit then sit:Destroy() end
		local BoardClone
		if turkish == false then
			if mir == false then
				if size == 10 then
					BoardClone = TenBoard:Clone()
					BoardClone.Name = "Set"
				else
					BoardClone = SetBoard:Clone()
					BoardClone.Name = "Set"
				end
			else
				BoardClone = MirBoard:Clone()
				BoardClone.Name = "Set"
			end
		else
			BoardClone = Turk:Clone()
			BoardClone.Name = "Set"
		end

		BoardClone.Parent = sets[random]
		BoardClone:SetPrimaryPartCFrame(sets[random].Location.CFrame)
		if mir == true then
			BoardClone:SetPrimaryPartCFrame(CFrame.new(BoardClone.PrimaryPart.CFrame.p) * CFrame.Angles(0, math.rad(-180), math.rad(-180)))
		end
		if mode == "Custom" then
			BoardClone.Config.Custom.Value = true
		end
		if mandjump == false then
			BoardClone.Config.Mandatory.Value = false
		end
		if bw == true then
			BoardClone.Config.BackJumps.Value = true
		end
		if fl == true then
			BoardClone.Config.FlyingKing.Value = true
		end
		if imrem == true then
			BoardClone.Config.ImRemove.Value = true
		end
		if maximum == true then
			BoardClone.Config.MC.Value = true
		end
		if restpromote == false then
			BoardClone.Config.RPromote.Value = true
		end
		BoardClone.Config.Nation.Value = convert
		local turn = {req, bot}

		turn[math.random(1,2)].Character.Turn.Value = false
		req.Character.Turn.Value = true

		local whiteplaying
		local blackplaying

		local botplaying
		local plrplaying

		if req.Character.Turn.Value == true then
			blackplaying = bot
			whiteplaying = req
			botplaying = 'Black'
			plrplaying = 'White'
		else
			whiteplaying = bot
			blackplaying = req
			botplaying = 'White'
			plrplaying = 'Black'
		end

		game.ReplicatedStorage.Interaction.TileClick.OnServerEvent:Connect(function(player, movetotile, selectedtile, color, capverify, selectedpiece, killed, Set, isBot)
			task.wait(2)
			if not isBot and "Set"..Set == BoardClone.Parent.Name then
				tileClick(BoardClone, botplaying, bot)
			end
		end)

		local WClone 
		if IGC:FindFirstChild(whiteplaying.Name) then
			WClone = IGC:FindFirstChild(whiteplaying.Name)
		else
			WClone = CloneMe(whiteplaying.Character)
			for _, v in pairs(WClone:GetDescendants()) do
				if v:IsA("BillboardGui") then
					v:Destroy()
				end
			end
		end

		WClone:SetPrimaryPartCFrame(WDummy.PrimaryPart.CFrame)
		WClone.Parent = IGC

		local BClone

		if IGC:FindFirstChild(blackplaying.Name) then
			BClone = IGC:FindFirstChild(blackplaying.Name)
		else
			BClone = CloneMe(blackplaying.Character)
			for _, v in pairs(BClone:GetDescendants()) do
				if v:IsA("BillboardGui") then
					v:Destroy()
				end

			end
		end
		BClone:SetPrimaryPartCFrame(WDummy.PrimaryPart.CFrame)
		BClone.Parent = IGC
		Inform:FireClient(req, whiteplaying, blackplaying, WClone, BClone, convert)

		req.Character.Humanoid.WalkSpeed = 0
		req.Character.Humanoid.JumpPower = 0
		wait(2)
		req.Character.HumanoidRootPart.Anchored = true
		wait(3.4)

		local selectedtile
		local jumping = false

		if botplaying == "White" then
			task.delay(3, function()
				tileClick(BoardClone)
			end)
		end

		if req.Character ~= nil and bot.Character ~= nil then
			req.Character.Spectate.Value = false
			BoardClone.Script.Disabled = false
			BoardClone.Timer.Disabled = false
			BoardClone.Draw.Disabled = false
			BoardClone.PlayerExists.Disabled = false

			BoardClone.Config.WhitePlayer.Value = whiteplaying.Character BoardClone.Config.BlackPlayer.Value = blackplaying.Character
			local place = BoardClone:WaitForChild("Player1")
			local place2 = BoardClone:WaitForChild("Player2")
			local loc = sets[random]:WaitForChild("Location")

			local function bigger(char)

				char.Humanoid.BodyDepthScale.Value = char.Humanoid.BodyDepthScale.Value * 13
				char.Humanoid.BodyHeightScale.Value = char.Humanoid.BodyHeightScale.Value * 13
				char.Humanoid.BodyProportionScale.Value = char.Humanoid.BodyProportionScale.Value * 13
				char.Humanoid.BodyTypeScale.Value = char.Humanoid.BodyTypeScale.Value * 13
				char.Humanoid.BodyWidthScale.Value = char.Humanoid.BodyWidthScale.Value * 13
				char.Humanoid.HeadScale.Value = char.Humanoid.HeadScale.Value * 13
			end

			removewaist(req.Character)
			--removewaist(bot.Character)
			bigger(req.Character)
			bot.Character:ScaleTo(13)
			--biggerBot(bot.Character)

			for i, v in bot.Character:GetChildren() do
				if v:IsA("BasePart") then
					v.Anchored = true
				end
			end

			whiteplaying.Character.HumanoidRootPart.CFrame = CFrame.new(place.Position.X, place.Position.Y + 1, place.Position.Z)
			blackplaying.Character.HumanoidRootPart.CFrame = CFrame.new(place2.Position.X, place2.Position.Y + 1, place2.Position.Z)
			whiteplaying.Character.HumanoidRootPart.CFrame = CFrame.new(whiteplaying.Character.HumanoidRootPart.Position, loc.Position)
			blackplaying.Character.HumanoidRootPart.CFrame = CFrame.new(blackplaying.Character.HumanoidRootPart.Position, loc.Position)
			BoardClone.Config.Competitors.Value = whiteplaying.Name .. " vs " .. blackplaying.Name
			BoardClone.Config.Started.Value = true
			wait(4)
		end
	else UA:FireClient(req)
	end
end

-- plr, piece, cap, false

game.Workspace.BotPlay.Torso.ProximityPrompt.Triggered:Connect(function(plr)

	botStart(plr, game.ReplicatedStorage.Bots.BotTemplate, "Ranked", false, false, false, "US/UK", false, false, false, false, 8, false)
	--"Ranked", true, true, true, "Pool", true, true, false, false, 10, false
end)