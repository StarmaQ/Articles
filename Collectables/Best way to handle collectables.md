It's very common for a game to have a sort of collectable objects system. Usually people go for the simplest strategies, such as the infamous loop through all objects in the game and make magnitude checks. Some spice things up and end up using a `Region3`, but still, updating a `Region3`, and getting all of the objects inside of it is still a really heavy process to do every frame. Today I will show you a great strategy for doing this!
____
The idea is rather basic, imagine that your game is made up of chunks.

 ![collectable1|371x368](upload://ql3fBcZJ2mpiQtNMXJc8dfN7g7f.png) 
The player is always gonna be in one of these chunks

![collectable2|371x368](upload://lTHjMX0Olimvj7M0V0f8D2y7gsL.png)

Each time, we need to check which chunk the player is in, and get all of the neighbouring chunks.

![collectable3|371x368](upload://yRokIb3Es4TojoWJkNchlGTkelt.png) 

Now here lies the efficiency of this algorithm, instead of having to make magnitude checks for all the collectables in the game (which is a lot!) we just do magnitude checks on the collectables that are inside of the chunk the player is in and all its neighbouring chunks. (We get the collectables by simply creating a region that surrounds all the chunks).

 ![collectable4|371x368](upload://hBbPVFRatuv4nc2z2lX2jeSiqaL.png)  
![collectable5|371x368](upload://qtcXKRzJffykPR3tRxwJ6d76ajj.png)

To the implementation!
___
To get things clear, we're not gonna have a table containing all of the chunks in the game. Depending on the player's position, and the size of each chunk, we can find out in which chunk the player is. Note that even though we're in 3D space, thinking of the chunks in terms of 2D makes things easier, mainly by looking from above. The X coordinate is width, the Z coordinate is height. Observe this first.

 ![collectable6|432x311](upload://jtVNNhvrx9vaPNb0riRCNHllXrz.png) 

We need to know how far off the player's position is from the chunk's right side, and the chunk's bottom side.

![collectable7|432x311](upload://uoaacTDCvqMsRHqwZeFViuN522d.png) 

We know each chunk's size (fyi chunks are squares). Let's say our chunks are 10 by 10. Technically, the right side's X coordinate has to be a multiple of 10, think about it. So, if we divided our player's X coordiante with 10, the remained of that should be how far off we are from the right side. Because you can imagine it, it's like subtracting the player's X from the distance between the chunk's right side and the first chunk's right side. Same for the Z coordinate, but in the image above the Z coordinate is actually less than 10 (because it's under the chunk's upper side) so the remainder of that is Z itself. We get the remainder of division using the modulus `%` operator.

![collectable8|432x311](upload://9Y8R2lvThIoUemIZyNQYtGnsEle.png)

```lua
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local HRP = character.HumanoidRootPart

local chunkSize = 10

while true do 
    task.wait()
    local pos = HRP.Position
    local x, z = pos.X - pos.X % chunkSize, pos.Z - pos.Z % chunkSize 
end
```
Why do we need these two values? Well because now since we know how far the player is from both sides, if we subtract the player's position (in reality `Vector3.new(HRP.Position.X, 0, HRP.Position.Y)`, we don't care about the Y coordinate) from `Vector3.new(x, 0, z)`, we get the lower right corner of the chunk, which is the yellow dot in the picture below.

![collectable9|432x311](upload://lljDiQO2YitqRx634oHQ3IwiBtE.png) 

Now this is exciting! From there, if we add `chunkSize/2` to both the X and Z coordinates, we get the chunk's center! The chunk's center is what defines the chunk. We now have the chunk the player is in.

![collectable10|432x311](upload://1fK0ntaqvgE6VlYgOV9TRgyRO6G.png) 

```
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local HRP = character.HumanoidRootPart

local chunkSize = 10

while true do 
    task.wait()
    local pos = HRP.Position
    local x, z = pos.X - pos.X % chunkSize, pos.Z - pos.Z % chunkSize 
    local chunk = Vector3.new(x + chunkSize/2, 0, z + chunkSize/2)
end
```
We can check if this work by creating a part to represent the chunk each iteration. A small snipet of code to do that:

```
-- ...

while true do 
    -- ...

    local part = Instance.new("Part")
    part.Size = Vector3.new(chunkSize, 1, chunkSize)
    part.Position = chunk
    part.BrickColor = BrickColor.Random()
    part.Anchored = true
    part.Parent = workspace
end
```


![collectable11|534x321](upload://tlfybbkweXZC8R8DMIISaeJTp2P.gif) 

Now to get the neighbouring chunks, that's rather easy, we just build a `Region3`. The `min` (first corner) of the `Region3` would technically be offset-ted by `-chunkSize*1.5` (one and a half of the chunk size) from both the chunk's center's X and Z. The `max` (second corner) of the `Region3` would technically be offset-ted by `chunkSize*1.5` from both the chunk's center's X and Z, the Y component here has to be set some value, the value depends on your game, if you have multiple floors in a building with collectables for example, you might not want the Y value to surpass the roof, it might also be wise to make the Y component the HRP's Y, not for this article though. Observe the image.

```
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local HRP = character.HumanoidRootPart

local chunkSize = 10

while true do 
    task.wait()
    local pos = HRP.Position
    local x, z = pos.X - pos.X % chunkSize, pos.Z - pos.Z % chunkSize
    local chunk = Vector3.new(x + chunkSize/2, 0, z + chunkSize/2)
    local region = Region3.new(chunk-Vector3.new(chunkSize*1.5,0,chunkSize*1.5), chunk+Vector3.new(chunkSize*1.5,10,chunkSize*1.5))
end
```
![image|498x437](upload://co0ij5NbvjWohMGzwwkYZpvnrQY.png)  

We're actually done! Now we just take all of the parts in that region, and do magnitude checks on them, the ones that are `distance` away from the player get an `E` on top of them, for demonstration I'll just be changing their color to Blue instead of Red. (The invisible part is the region).

![iai9uNddSq|804x538, 75%](upload://fg50OqyOPgObsNxkUmJKQzHYcaJ.gif) 

```
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local HRP = character.HumanoidRootPart

local chunkSize = 10
local distance = 10 --arbitrary distance for the magnitude checks
local previous = {} --this will contain the previous parts, used to turn them back to their original state each time

while true do 
    task.wait(0.25) --I found 0.25 suitable in this situation, depends on the chunk's size 
    local pos = HRP.Position
    local x, z = pos.X - pos.X % chunkSize, pos.Z - pos.Z % chunkSize
    local chunk = Vector3.new(x + chunkSize/2, 0, z + chunkSize/2)
    local region = Region3.new(chunk-Vector3.new(chunkSize*1.5,10,chunkSize*1.5), chunk+Vector3.new(chunkSize*1.5,0,chunkSize*1.5))
    for i, v in pairs(previous) do --reset previous parts
        if v.Name = "collectable" then --of course want only the items that are supposed to be collectables, here I just renamed them, but in an actual game I would either use CollectionService, or perhaps a ValueObject inside of the collectables
            v.BrickColor = BrickColor.Red()
        end
    end
    previous = workspace:FindPartsInRegion3(region)
    for i, v in pairs(previous) do --tag the new ones
        if (v.Position - pos).magnitude <= distance and v.Name == "collectable" then
             v.BrickColor = BrickColor.Blue()
        end
    end 
end
```

We have a much more efficient system now! Why? Well instead of updating 60 times a second using RenderStepped (assuming you're running on a smooth 60 fps) we're only updating 4 times a second, which can be reduced even more for larger chunkSizes. That's 15 times better! We're even doing less stuff each time, instead of looping through all objects in a game, we're just looping through a very small amount, creating a `Region3` each time but that's nothing. 

Note that I decided to use a while loop just for the sake of simplicity, in reality using a loop with a small waiting time like 0.25 is bad and can be affected depending on the game's performance. Another solution is what tralalah suggested.

This same system can be used for multiple stuff, if you had a zombie game where they run towards the player, this might be a way to implement it, instead of informing all of the zombies in the game.

Here is a place that has an actual "Press E to Collect" type of thing, really naively made though. [bestcollectable.rbxl|attachment](upload://kSfRcl1V3VzqsiE7788RMBJn4ed.rbxl) (22.6 KB) 

As usual, have a wonderful day!
