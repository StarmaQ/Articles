This article is the answer to the famous question "How to save objects using Datastore" and many other ways to word it.

----

If you played with `Datastore` for enough time, I think you already know that Instances such as parts and models ect. can't be simply saved using `:SetAsync()`, which makes it hard to save objects. Most people, with games that are supposed to have slots and stuff on them that you want to save, get stuck when doing this, although, I think finding a way to go over this is quite easy.

To keep it short, a way to store objects, is to convert them into dictionarries, where each key is a property of that object, and each value is the value of that corresponsind property.

Meaning, if I had a part named `"Bob"`, with Transparency set to `0.5`, and Anchored to `true`, we would convert it into something like this:
```lua
{Name = "Bob", Transparency = 0.5, Anchored = true}
```

This my friend, is called **serialization**.

By definition, serialization is taking a piece of data that can't be saved or transfered through the network, and turning it into a piece of data that can be saved or transfered through the network.
Like in our case, a part can't be saved, which is why we serialized it so we can save it.

Why can't certain pieces of data be saved or transfered? Well, that idea is meant to be abstracted away from the user, just know that some things can't be saved and you have to serialize it. For example, if you were displaying an image, and the way you were displaying that image was by retrieving it's address (directory or hierarchy inside the computer, like 
 `D:/Images/WantedImage`), what if you wanted to send that information over the internet? You can't just send your computer's hierarchy, other computers won't have that same image in that placement, they might not even have that placement. You need to serialize that image, by converting it into an array containing each and every pixel of that image!

So let's carry on. What if I want to load the data after saving? Meaning I want to **deserialize** that table. In a self explainable way, deserialization is that taking that piece of data that's compatible with saving and sending, and turning it into its usable original form that it had before the serialization.

Since we have the ability to do `object[prop]` (`part.Transparency` is the same as `part["Transparency"]` for example), what we can do is: create the part, then loop through the dictionarry, where `key` is the current property and `value` is the current value it's set to, and do `part[prop] = value`. This might sound complicated, don't worry, we're doing this later.

What if we wanted to save other properties? Such as `Position` or `BrickColor`? Well we're gonna come across other problems. All userdatas such as `Vector3`s, `Color3`s, `BrickColo`rs, `CFrame`s ect. can't be saved using Datastore as well. We have to serialize those as well! 

There isn't one exact way to serialize, you just have to get creative and invent your own way to do it:
*  If I wanted to serialize a `Vector3`, I could turn into a dictionarry with 3 keys, an `X`, a `Y`, and a `Z` components. And when I deserialize, I simply do `Vector3.new(t.X, t.Y, t.Z)`, where `t` is the saved dictionarry. 
* For `BrickColor` I can simply `tostring()` it, then do `BrickColor.new(str)` where `str` is the saved string. 
* `CFrame`? This can be done in multiple ways. Since a `CFrame` is made up of a `cf.Position`, and a `cf.rightVector`, `cf.upVector`, `-cf.lookVector`, we can save those in a dictionarry as well with 4 keys, and when we deserialize, we  `CFrame.fromMatrix(t.Pos, t.rX, t.rY, t.rZ)`, where `t` is the saved dictionarry, and `t.Pos` is `cf.Position`, `t.rX` is `cf.rightVector`, `t.rY` is `cf.upVector` and `t.rZ` is `-cf.lookVector` (`-lookvector` and not just `lookvector`). Wait a second. aren't these 4 values `Vector3`s? We have to serialize, then deserialize them as well! 

* `Color3` might be simple, since `Color3`s have a `.R` and a `.G` and a `.B` property, we can save those in a dictionarry like `Vector3`s, but here is a better suggestion, using `Color3:ToHSV()`, which converts an RGB value to an HSV value, save that returned tuple in a table `t = {Color3:ToHSV()}`, then to deserialize do `Color3.fromHSV(unpack(t))`.

* What about properties that are set to `Enum` values? These ones might be tricky! The way I did it was by `tostring()`ing it, then since `Enum`s have each part seperated with a `.` (for example `Enum.Material.Plastic`), I can do `string.split` on it where `"."` is the seperater, and like that I have a table containing `{"Enum", "Material", "Plastic"}`, then what I do is save the 2nd and 3rd index, and when I deserialize, since `Enum.Something` is the same as `Enum["Something"]`, I can do `Enum[t[1]][t[2]]`, where `t` is the saved table containing `"Material"` and `"Plastic"`, and `t[1]` is `"Material"` and `t[2]` is `"Plastic"`.

![serializer1|690x232](https://github.com/StarmaQ/Articles/blob/master/Serialization/Imgs/serializer1.png) 

Again! All this might sound complicated, but it will be made clearer later on in the code!

Important question:  How would the saved table look? Remember that the *slot* that we're saving will have many objects with different classes. Simply, it's best for it to be a dictionarry, where each key is the class of the saved object. Each key will have a table containing all of the serialized objects with that corresponding class.
```lua
local savedTable = {
Part = {"here we'll put all objects with the class Part"},
Decal = {"all objects with the class Decal here"},
SpawnLocation = {"all objects with the class SpawnLocation"}
}
```
Another important question: What if an object had children? You can probably save the `.Parent` property, but that's gonna be complicated. What we can do is have a key inside of each serialized object, called `Children`, that's set to table which will have the same layout as `savedTable`! It will also have keys to represent classes, and each child of that serialized object will fall under the corresponding class. The children will as well be serialized seperately, like their parent. And if a child had a child, welp same thing! Have a `Children` table inside it. And if its children have children, add a `Childern` table yet again! We'll see how this is done later (again hehe).

Another important question: How exactly will we determine what properties are check? If you think about it, different classes have different properties, and as well we don't want to save all properties, just certain ones? To do that, let's say we have a table called `Properties`, that will store the properties that we wanna save for each class, represented as strings containing the propertie's name.

```lua
local Properties = {
Part = {"Name", "Position", "Size", "Transparency", "BrickColor", "CanCollide", "CFrame", "Anchored", "Shape", "Material"}
Decal = {"Name", "Texture", "Transparency", "Face", "Color3"}
}
```
As you'll see, the usefullness of this will be made clear later on (yet again).
This table is supposed to be modifiable, if you want to save certain properties, write those properties that you want. If you want to serialize more objects, add their class. ect.

So finally! Let's start coding this!

We'll start with the serialization of properties, creating the function responsible for it. Then we will take care of objects. Let's start with properties first.

This function will take the value of a property as input, and return the serialized version. We will just be implementing what we talked about earlier.
```lua
local function Serialize(prop) --prop will be the property's value
 	local typ = typeof(prop) --the type of the value
	local r --the returned value afterwards
	if typ == "BrickColor" then --if it's a brickcolor
		r = tostring(prop)
	elseif typ == "CFrame" then --if it's a cframe
		r = {pos = Serialize(prop.Position), rX = Serialize(prop.rightVector), rY = Serialize(prop.upVector), rZ = Serialize(-prop.lookVector)}
	elseif typ == "Vector3" then --if it was a vector3, this would apply for .Position or .Size property
		r = {X = prop.X, Y = prop.Y, Z = prop.Z}
	elseif typ == "Color3" then --color3
		r = {Color3.toHSV(prop)}
	elseif typ == "EnumItem" then --or an enum, like .Material or .Face property
		r = {string.split(tostring(prop), ".")[2], string.split(tostring(prop), ".")[3]} 
	else --if it's a normal property, like a string or a number, return it
		r = prop
	end
	return r 
end
```
Great! You can test it if you want. One thing to point out, notice when dealing with CFrame, I'm using `Serialize` inside of  `Serialize`, because as we said earlier, a serialized CFrame is made up of 4 Vector3s, so you have to serialize them as well. We'll look into this more later, since this is the same thing that we'll do with the `Children` table.

Now, let's serialize objects! I'm gonna make a function called `InitProp` (Init just stands for initiate). This function will take an array of objects as input, and return an array of the serialized verions of the objects. 

We'll have a table called `tableToSave`, which will be the saved table, that will contain all of the saved classes, and the saved objects with their corresponding, this is pretty much the first table I mentioned at the start. What we will do is, loop through the inputed array, and each time we check if a key corresponding with the current object's class exists inside of `tableToSave`, if not create it inside of that table. Then, we will initiate the object's properties. For each object, we will create a table called `add` that will be the object's serialized form, the one that holds the properties as keys, that we mentioned all the way at the start. The way this will work, is by getting the table from `Properties` corresponding with the object's class (the properties we want to save for this class), loop through those properties, doing `add[prop] = Serialize(obj[prop])` where `prop` is the current property from the properties tables. Basically, what we're doing is: make a key inside of the serialized object (`add`) table representing that property (`add[prop]`, creating a key inside of `add` with the name of property), and set to the serialized version of the property (`Serialize(obj[prop])`, `obj[prop]` is the value the property is set to). Basically, we're turning the instance, into that serialized table form we talked about from the start. 

```lua
local function InitProps(objects) --objects is the array of the objects to serialize
	local tableToSave = {} --the table that will hold the serialized versions of objects
    for _, obj in pairs(objects) do
	     local class = obj.ClassName --the object's class
        
	     local t = tableToSave[class] --this is the class table containing all the saved objects with the same class
		 if not(t) then --check if that class table existed
		 	 tableToSave[class] = {} --if not, create it
		 	 t = tableToSave[class] --save a reference to it
		 end

         local add = {}  --the current serialized object that we will be filled with properties
	     for _, Prop in pairs(Properties[class]) do --Prop will be the property corresponding to the class, notice how we're doing obj.ClassName, to get the properties for that wanted class, doing _ pretty much says I don't need this value it's useless, which is why I did it
		     add[Prop] = Serialize(obj[Prop]) --do the magic
	     end
         table.insert(t, add) --insert the magic after all properties are initiated into its class table
    end
    return tableToSave --return the magic after all objects are initiated
end
```
Simple right? Maybe not, which is why I advise you to take another look to understand what's going on more. If you want a cleaner version of the code uncommented, [here](https://github.com/StarmaQ/Articles/blob/master/Serialization/serializer.lua) ts is.

What about the Children part? Well, here I'm gonna introduce a new idea, but first let's talk about what we're gonna do: We will be checking if the current object had children (if `#obj:GetChildren() > 0`), if so, we create a `Children` table inside of its serialized table `add`, and we'll be littearly re-creating what we already did with `tableToSave`, make a place for the classes, and initiate serialized objects and their properties into them. Isn't that littearly the same thing `InitProps` does? Can't we just set the `Children` table to `InitProps(obj:GetChildren())`?  Yes, we can.

This my friend is called **recursion**. Recursion is making a function call itself over and over again until it hits a deadend, a base case where it has to stop (and yes, a function can call itself). In our case, let's supposed an object had children, and its children had children. What would happen in the code is: initiate the object, then initiate its children, then initiate its children's children. We if we didn't know how many descendants there was? We can't use a for loop since we don't know. We can use recursion! If we implemented recursion what would happen is the function will keep on calling itself, initatiating the original objects, then initiating its children, it finds out that its children had children, and initiates its children, then it resumes the rest of initiating. I know, complicated indeed, sorry if you did not understand, so [here](https://www.youtube.com/watch?v=Mv9NEXX1VHc) is a good resource. Another example is with the CFrame serialization earlier, as we saw we had to serialize the vectors as well, we were calling `Serialize` inside of `Serialize`.

And we should be done!
```lua
local function InitProps(objects)
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
		local children = obj:GetChildren() --the children
		if #children > 0 then --if it has them
			add["Children"] = InitProps(children) --initiate the children
		end
		table.insert(t, add)
	end
	return tableToSave
end
```

If we were to `game.HttpSerivce:JSONEncode()` the returned table (we're gonna use this even more) and printed.
We will get this:
![image|690x201](https://github.com/StarmaQ/Articles/blob/master/Serialization/Imgs/serializer2.png) 
Pretty cool right? You can see the serialized stuff.

And finally, we can wrap all this into one beautiful and basic function named `Encrypt` which is going to be the one we mainly use.
```lua
local function Encrypt(objects) --objects is the array of object I want serialized
	return game.HttpService:JSONEncode(InitProps(objects)) --I instanly input it to InitProps
end
```
Notice how I'm using [`:JSONEncode()`](https://developer.roblox.com/en-us/api-reference/function/HttpService/JSONEncode), which converts a table into a stringified JSON object (JSON stands for JavaScript Object Notation, in object in Javascript is basically what we call a dictionarry in lua, JSON is universally used in programming to store info, [more](https://www.w3schools.com/whatis/whatis_json.asp) info). It's advised to use `JSON` as another way to serialize data, which is why I did, plus it's better to store a string than a dictionarry in Datastore. We can deserialize the data after using `:JSONDecode()`.

After that, and simply, you can save the value returned from `Encrypt` with `:SetAsync()`, beacuse it's a string.

Now! Let's move on to the deserialization! Or otherwise called, loading.

Again, we'll start with the properties, as we talked earlier about serializating and deserializing proprites.

We'll call this function, where `prop` is the name of the property (to not be confused with the previous `Serialize` function, where `prop` was the property's value) and `value` is the property's value. Again we talked about all this later.
```lua
local function Deserialize(prop, value)
	local r --this will be the returned deserialized property
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
	return r --return it
end
```
Here we have to check for the property's name, and not the value's type, because with just the value given, I can't know to what value I should serialize that; I could get a string, a string can be a serialized BrickColor value, or it can be just a string for a `.Name` property. 

Now, to deserializing objects! We will call the function `Create`. It will take two parameters, where `parent` is the object you want to parent all objects to (children will still be parented to their original parent of course), and `t` is the `:JSONDecode()`'d version of returned JSON string from the `Encrypt` function, which is why uou need to use `:JSONDecode()` on it before inserting it as a parameter.
The way this function will work is, by looping through the saved dictionarry (after it was decoded), and in each class table, loop through the serialized objects, each time create an object with the current table's class, then loop through the serialized object, and setting the created object's property which is currently `prop`, to the deserialized property's value `Deserialize(prop, value)`, inserting the current property's name `prop` and its value `value` to `Deserialize`, pretty simple.
Again with recursion, if we find a `Children` table, we call `Create` on it, where the parent is the created object and it's the list of serialized objects. If `Children`'s objects had `Children`, it will take care of them as well, recursion works.

```
local function Create(parent, t) 
	for class, _ in pairs(t) do --loop through classes, notice how I want class which is the key, I don't need the value so I do _
		for _, obj in pairs(t[class]) do --loop through class's serialized objects
			local object = Instance.new(class) --create the new object with the wanted class
			for prop, value in pairs(obj) do --loop through the serialized object's props and values
				if prop ~= "Children" then --we need to check if the current key inside of the serialized table is not the Children table
					object[prop] = Deserialize(prop, value) --do the magic
				else
					Create(object, value) --if it is the Children table, take care of it
				end
			end
			object.Parent = parent --parent it to the parent
		end
	end
end
```
And that's it! Great!
We're actually done, finally I'm just gonna make another nice wrapper for this function called `Decrypt` where `dic` is the returned JSON string from `Encrypt` which I decode later, `slot` is the parent of the list of objects.
```lua
local function Decrypt(dic, slot)
	local t = HttpService:JSONDecode(dic) --decode it
	Create(slot, t)
end
```
We can now `:GetAsync()` the saved JSON string, and decrypt it to spawn the objects back!
And we're done! Hooray! 

I took the liberty to turn it into a [module](https://github.com/StarmaQ/Articles/blob/master/Serialization/serializer.lua) and create a place to test it out, it's fully commented (besides the serializer module) and you can download it!
[Here](https://github.com/StarmaQ/Articles/blob/master/Serialization/serializer_place.rbxl)


```lua
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


function module.Encrypt(objects)
	return HttpService:JSONEncode(InitProps(objects))
end


function module.Decrypt(dic, slot)
	local t = HttpService:JSONDecode(dic)
	
	Create(slot, t)
end


return module
```

Again, and as usual, have a wonderful day!
