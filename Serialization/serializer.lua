local module = {}

local HttpService = game:GetService("HttpService")
local Properties = {
Part = {"Name", "Position", "Size", "Transparency", "BrickColor", "CanCollide", "CFrame", "Anchored", "Shape", "Material"},
Decal = {"Name", "Texture", "Transparency", "Face", "Color3"}
}

function Serialize(prop)
	local typ = typeof(prop)
	local r 
	if typ == "BrickColor" then
		r = tostring(prop)
	elseif typ == "CFrame" then
		r = {pos = Serialize(prop.Position), rX = Serialize(prop.rightVector), rY = Serialize(prop.upVector), rZ = Serialize(-prop.lookVector)}
	elseif typ == "Vector3" then
		r = {X = prop.X, Y = prop.Y, Z = prop.Z}
	elseif typ == "Color3" then
		r = {Color3.toHSV(prop)}
	elseif typ == "EnumItem" then
		r = {string.split(tostring(prop), ".")[2], string.split(tostring(prop), ".")[3]}
	else
		r = prop
	end
	return r
end

function Deserialize(prop, value)
	local r 
	if prop == "Position" or prop == "Size" then
		r = Vector3.new(value.X, value.Y, value.Z)
	elseif prop == "CFrame" then
		r = CFrame.fromMatrix(Deserialize("Position", value.pos), Deserialize("Position", value.rX), Deserialize("Position", value.rY), Deserialize("Position", value.rZ))
	elseif prop == "BrickColor" then
		r = BrickColor.new(value)
	elseif prop == "Color" or prop == "Color3" then
		r = Color3.fromHSV(unpack(value))
	elseif prop == "Material" or prop == "Face" or prop == "Shape" then
		r = Enum[value[1]][value[2]]
	else
		r = value
	end
	return r
end

function InitProps(objects)
	local tableToSave = {}
	for _, obj in pairs(objects) do
		local class = obj.ClassName
		local t = tableToSave[class]
		if not(t) then
			tableToSave[class] = {}
			t = tableToSave[class]
		end
		local add = {}
		for _, Prop in pairs(Properties[obj.ClassName]) do
			add[Prop] = Serialize(obj[Prop])
		end
		local children = obj:GetChildren()
		if #children > 0 then
			add["Children"] = InitProps(children)
		end
		table.insert(t, add)
	end
	return tableToSave
end

local function Create(parent, t)
	for class, _ in pairs(t) do
		for _, obj in pairs(t[class]) do
			local object = Instance.new(class)
			for prop, value in pairs(obj) do
				if prop ~= "Children" then
					object[prop] = Deserialize(prop, value)
				else
					Create(object, value)
				end
			end
			object.Parent = parent
		end
	end
end


function module.Encode(objects)
	return HttpService:JSONEncode(InitProps(objects))
end


function module.Decode(dic, slot)
	local t = HttpService:JSONDecode(dic)
	
	Create(slot, t)
end


return module
