I'm sure you once were wondering how would you make the player able to drag objects around with his mouse, just like in Lumber Tycoon for example.



It is certain that someone who had some decent knowledge with the mouse object has tried to make this by himself utilising the [`mouse.Hit`](https://developer.roblox.com/en-us/api-reference/property/Mouse/Hit) property of the mouse, which is the CFrame of the mouse in the 3D world. 

We would set whatever the current `mouse.Target`, the part that the mouse is currently hovering over, to the `mouse.Hit.Position`, the position of the mouse in the 3D world (any CFrame has a .Position or .p (.p is out-dated) property which is *just* the position of that cframe (remember that cframe is position and rotation). We can technically set the CFrame of the target straight away to mouse.Hit and not just the position but the rotation is kind of broken) each time the [`mouse.Move`](https://developer.roblox.com/en-us/api-reference/event/Mouse/Move) event fires and only when the mouse is pressing down. Also setting the [`mouse.TargetFilter`](https://developer.roblox.com/en-us/api-reference/property/Mouse/TargetFilter) to the target itself so the mouse ignores the target while calculating the `mouse.Hit` to prevent many issues. 

So your attempt will look like something similar to this
```
local player = game.Players.LocalPlayer --the local player
local mouse = player:GetMouse() --his mouse
local target --this variable will hold the part that's being currently dragged
local down --this determines wether we are pressing or not

mouse.Button1Down:connect(function() 
	if mouse.Target ~= nil and mouse.Target.Locked == false then --checking if the mouse is actually hovering over an object, the locked property isn't really important
		target = mouse.Target --the target is set
		mouse.TargetFilter = target --preventing issues
		down = true  
	end 
end)

mouse.Move:Connect(function()
	if down == true and target ~= nil then --this event will be always firing, but we wanna change the target's position only when clicking, that's why we check if down is true
		target.Position = mouse.Hit.Position --the part that sets the position!
	end 
end) 

mouse.Button1Up:connect(function()
	down = false --and remember that after ending the holding, you wanna reset some properties
	mouse.TargetFilter = nil 
	target = nil
end)

```
![](https://github.com/StarmaQ/Articles/blob/master/Mouse/Imgs/drag1.gif)  

Great efforts! 

This would work, but not totally according to the plan. The parts would always be sticking to the ground; since really the mouse's position is constanly landing there, it's not in thin air. And even if you tried to drag the objects around in the sky above your head where there is nothing, they just disappear. 

Perspective has a huge role in what's going on.

 What's happening is, whenever you drag the mouse in the air, you'd think that the `mouse.Hit` is in the air as well. But the `mouse.Hit`, when calculated, will go in the same direction that the mouse is hovering in until it hits a surface. A way to prove that is, you try to drag it up in the air where there is no surface to land on, the part littearly dissapears because the `mouse.Hit` will go on until it hits its maximum length, so the part is really far away. You can even print the `.Magnitude` of the `mouse.Hit.Position` while hovering the mouse in empty space and you'll see that it's a large number (Any Vector3 has a .Magnitude or a .magnitude property, which is the length of the vector, magnitude is basically length, size or anything that goes along that).
```
print(mouse.Hit.Position.Magnitude) --9986.2734375, always rounds to 9986
 ``` 
![](https://github.com/StarmaQ/Articles/blob/master/Mouse/Imgs/drag4.png) 




---
Side Note:
The mouse's origin is actually the current camera's position, and in the above image it was the head. 

For the entirety of the tutorial, I'm gonna be showing examples where the mouse's position starts from somewhere else that is not the camera because I can't really draw it from the camera's position, it would be complicated in a 2-dimensional picture. So just remember, the mouse's origin is the camera and not actually where I drew it from! 

The camera's position would always be the point of view from where the player is looking, and if he's in first person the camera's position is inside of the head; which means that some of these examples might be right if you consider the player to be from a first person perspective.

  ![](https://github.com/StarmaQ/Articles/blob/master/Mouse/Imgs/drag9.png)
  ![](https://github.com/StarmaQ/Articles/blob/master/Mouse/Imgs/drag10.png)
---





Technically, in order to make this work as wanted, we would have to *limit* how much the mouse goes, so it doesn't go all the way in. To do that 
``` 
mouse.Target.Position = mouse.Hit.Position.Unit * 20
```
 `mouse.Hit.Position.Unit` is simply the direction of the `mouse.Hit.Position` (any Vector3 has a `.Unit`  or a `.unit` property, it is the direction of that vector3), but if you wanna dig deeper, .Unit gives back a **unit vector**. 

Unit vectors are vectors with a length of one, and they are used to describe directions. These guys are one-long because we don't really care about their length, just their direction, and also it's helpful when multiplying (multiplying vector A by unitvector B, changes A's direction to B's direction, without changing the length of A because B's length is 1). 

So again, `.Unit` is the direction of the given vector (given in the form of a unit vector). After, we multiply this `mouse.Hit.Position.Unit` by a number (or also called a scalar), because remember `.Unit` gives a vector with a length of one, which is not long enough, so we have to "scale" this vector, I recommend something like 20. So to wrap it up, what we did is made a new vector with the same direction as `mouse.Hit.Position` but is only twenty-studs long.

                               ![](https://github.com/StarmaQ/Articles/blob/master/Mouse/Imgs/drag5.gif)
 After applying this to the script, we have this

 ![](https://github.com/StarmaQ/Articles/blob/master/Mouse/Imgs/drag3.gif)

 Welp, it is being dragged in the air like we wanted, but it is not exactly where the mouse is. 

This is happening because, the part's origin is `(0, 0, 0)` just like any part, while the mouse's origin is the camera's position (the origin in the picture down below is wrong, it can be considered right if the player was in first person). You can think of them orbiting around each of their origins which won't work out. The part is being offseted relative to `(0, 0, 0)` unlike the mouse.


 ![](https://github.com/StarmaQ/Articles/blob/master/Mouse/Imgs/drag6.png) 
 
In order to fix this, we have to change the part's origin to the camera by simply setting its position to the camera's position, and then offset it by the twenty-long vector. The origin of a vector isn't really a property of the Vector3 class, it's just from where your vector mathematically starts; Offsetting position A relative to position B makes position B act up like position A's origin.
 ``` 
local camera = workspace.CurrentCamera 
mouse.Target.Position = camera.CFrame.Position + (mouse.Hit.Position.Unit * 20)
 ``` 
But even with doing this, it is kind of fixed, but still buggy. What we can do is find a better direction of the mouse, something else to replace `mouse.Hit.Position.Unit`, and for that we can use the [`UnitRay`](https://developer.roblox.com/en-us/api-reference/property/Mouse/UnitRay) property of the Mouse. This property is a ray that has the direction of the mouse, so we can probably use its `.Direction`! (again, any ray has a `.Direction` property, the direction of that ray, which I think you've guessed it, is a unit vector).
```
mouse.Target.Position = camera.CFrame.Position + (mouse.UnitRay.Direction * 20) 
``` 
That's it! It actually works perfectly, we can now drag stuff in the air *like we just don't care*.

![](https://github.com/StarmaQ/Articles/blob/master/Mouse/Imgs/drag8.gif) 

 And of course, there are always multiple ways to achieve something. 

For instance, we could've used some raycasting with the `.UnitRay`, since this property is a ray in the first place. Using the `:FindPartOnRay()` method, we can get the position of where the ray landed, which is technically an alternative to `mouse.Hit`. We have to take count that *Unit* Ray goes only 1 stud out, so we need a longer ray. Multiplying rays or doing any math operation on them isn't possible, so we have to make a new ray, with the same `.Origin` and same `.Direction` as the unitray, but longer. 

```
function mouseHit(distance) 
   local ray = Ray.new(mouse.UnitRay.Origin, mouse.UnitRay.Direction * distance) --as you can see, here creating a ray with the same origin (which is the camera of course) and the same direction BUT longer, whatever the distance parameter is
   local _, position = workspace:FindPartOnRay(ray)

   return position 
end

 mouse.Target.Position = mouseHit(20)
 ```
 Or, we could is mess a bit with the target's cframe, and simply setting it to 20 studs from the head facing the `mouse.Hit.Position`

 ```
 mouse.Target.Position = CFrame.new(CFrame.new(character.Head.Position, mouse.Hit.Position) * Vector3.new(0,0,-20)).Position
 ```
And also if you want here is a much different and advanced [system](https://www.roblox.com/games/3661208893/Dragging) that you can check it out (it's uncopylocked) made by @BenSBk! 

 Another final thing that we can do, is make the target move more smoothly torwards the mouse by inserting a [`BodyPosition`](https://developer.roblox.com/en-us/api-reference/class/BodyForce) to it while dragging, and of course removing it after we are done, we might as well add a [`BodyGyro`](https://developer.roblox.com/en-us/api-reference/class/BodyGyro) to make it so the part's rotation doesn't freak out. A side note, body movers don't work with anchored objects, so for a substitution simply use tweening.
```
local player = game.Players.LocalPlayer 
local mouse = player:GetMouse() 
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService") --we will use this service for something later
local target 
local down



mouse.Button1Down:connect(function() 
	if mouse.Target ~= nil and mouse.Target.Locked == false then
		target = mouse.Target 
		mouse.TargetFilter = target 
		down = true 

		local gyro = Instance.new("BodyGyro") --adding the forces
		gyro.Name = "Gyro"
		gyro.Parent = target 
		gyro.MaxTorque = Vector3.new(500000, 500000, 500000)
		local force = Instance.new("BodyPosition") 
		force.Name = "Force" 
		force.Parent = target
		force.MaxForce = Vector3.new(10000, 10000, 10000) --you may wanna modify this a bit, since it effect if you can move an object or wrong depending on its weight/mass (in other words, the force might not be strong enough)
	end
end)

game:GetService("RunService").RenderStepped:Connect(function() --replaced the move event with renderstepped because it works better in some cases, renderstepped is an event that fires every frame, basically super fast, look it up it is important!
	if down == true and target ~= nil then 
		target.Force.Position = camera.CFrame.Position + (mouse.UnitRay.Direction * 20)
	end 
end) 

mouse.Button1Up:connect(function() 
	if target then --of course we wanna remove the forces after the dragging, first check if there was even a target
		if target:FindFirstChild("Gyro") or target:FindFirstChild("Force") then --check if there was a force
			target.Gyro:Destroy() --DESTROY!!!!
			target.Force:Destroy()
		end
	end
	down = false
	mouse.TargetFilter = nil
	target = nil 
end)
```

That's it, have a wonderful day!
