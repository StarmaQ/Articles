Whenever you're talking about OOP, which stands for **O**bject-**O**riented **P**rogramming, remember the two terms; `class` and `object`. So yeah, OOP is basiclly manipulating classes and objects, what do these things mean? Welp, let's start with a class. 

Most articles and videos describe a *class* as a *blueprint* of somesort, a blueprint containing a bunch of properties, and methods. I'm sure you are familiar with properties in roblox, for example the Name property, or the Position property, properties are like an adjective of somesort. For example how much you age, your hair colour and all that. A method, is just a fancy synonym to a function (well not totally since there is a minor difference but think of it like tht for now), like the built-in functions roblox provides, like `:Destroy()` for example or `:GetFullName()`.
Now, if we go with that, remember that a class is a blueprint, or simply a list of properties and functions

Now talking about *object*s,  objects are constructed from a class, so if you have a class that has some properties and methods, we can create an object out of that class, this object will hold all of the properties and functions that were inside of that class. And we can create as many objects as we want; and think about this, a class would have the properties, but they would not be set to anything, they are not set to a value, they are there so we know that when an object is created out of that class, it'll have these properties. But when we create an object out of a class, the object will have those properties, and we can set them to a value we want, and different objects out of the same class have the same properties, but they can be set to different things. Methods though, those are set just in the class, and any object out of that class can use them.

Ok so, I hope I made things a bit clear, but I still think this is complicated, so let's make an example.
So, in our world, there are many many cars, but with *different* colors and *different* speeds for example. But after all, they are all just, a Car, even though they are all different. Or a humans for example, there are male and female, but they are all just a Human. Now my friend, these many ideas may start ticking and linking in your head. So going back to the Car example, think of that Car as a class.
Just think of a blank car, that has nothing to it, and out of that car we would create other cars with different characteristics.
We would put some properties to it and some methods, for example..

![OOP](https://i.ibb.co/TT3RnZ0/OOP-article.png)

This would be our "Car" class, and as I said earlier, this contains our properties, but they are not set to anything, for example Speed is just sitting their, it isn't like 'speed = 15', But when we create an object, or a car out of this class we can set these properties to a value we want, and we can even use some functions on it.

So, let's make 2 different cars. Now, I might've made things a bit unclear here since I kind of stumbled into the scripting part without explaining much, but i'll show you a bit and then explain way better later on. So while making classes and objects, in order to make an object out of a class, we need to use a *constructor function* on the class. For example, when you do `Vector3.new()` that **.new** is the constructor function. Let's say you have a class called "Car", in order to create an object out of it while you're scripting you do *ClassName*.new(), our constructor function, to construct an object of this class, and you put in the arguments which are the values set to the properties for the created object. So just don't complicate stuff, think of the Car1 and Car2 variables as our objects, forget about that constructor stuff, and remeber it later.
And yes, if you're wondering, a Vector3 value, is indeed an object... . And the `:Boost()` function adds to the speed of the given object the value that the user inserted as the argument for the function.

This is our example, 2 cars, taken from the Car class, with different *speed* and *colour* properties, and we use `:Boost()` on one of them. As I said the Car1 and Car2 are our objects.

![alt text](https://i.ibb.co/BPW7L9k/OOP-article-2.png)


As you can see, out of our Car class, and just think that that class exists, because we didn't make it in the script, we made some objects, Car1 and Car2 with different properties, and we used the `:Boost()` function which boosted the speed property of Car1 by 5, and we can see we do `Car1.speed` or .color for the property, and even do `Car1:Boost()`. We are littearly working with an object.

And if you're sick of real life things examples, another super simple example, is just straight up roblox classes and objects. For example the Part class.

![alt text](https://gyazo.com/cb7741eafa51fd744c7999016a89ff18.gif)

You can see, the Part class contains many methods and properties (and also events but let's just not talk about those, they are a part of a class though)
And I can create 2 objects from this class with different properties, and maybe even use a method on it.

![alt text](https://gyazo.com/777b63df3b97e553ecba8cf2be6c7d70.png)

Another good example is Minecraft, that surely uses a lot of OOP due to the amount of items there are, each item has its class.








**Scripting Part**
---
Now, after you understood how objetc-oriented programming works, I'll show you how to script your own classes and objects.
Prerequisites though:
* An understanding of meta-tables, all though don't worry I'll explain everything
* And a general intermediate knowledge of scripting


So, if we would think about an object, it can technically be a table, right? A table containing some varibles that will represent the properties of the object, for exemple a speed property, we can set that variable inside of the table, holding that value of speed, and due to the lua syntax, we can make that varibale look like its 
actually a property.
```
local CarObject = {speed = 15, colour = "FiftyFive"}
CarObject.speed = 100
print(CarObject.speed)
```
Well that's cool, but whenever we create an object, we don't want to do it manually. We don't want that crap, we want a class, and some sort of thing that will make u an object out of that class, this whee **constructor functions** come in, which we deffintly didn't talk about earlier! You can say, we are making our own `Instance.new()`. Other constructor for example, `CFrame.Angles`, you can really name them whatever you want, but most commonly we do *.new*, and yes CFrames and Vector3 do act up like object made in roblox. Now let's make that function. And now we will make a table called Car, that's our class you may say.

```
Car = {}

function Car.new(speed, colour, driver)        

end
```
Now wait, that's some weird stuff their isn't it? I made this hard didn't I, well, simply, waht we wanna do is; we putting our constructor function into our table in a different way. And for begginers, when we do (`table.name = "value"`), you are automaticlly making a variable inside of that specific that. And also, "variables" that are inside of a table are called *fields*, but I kept on saying variables, so sorry, remeber, these are "fields". That's why we can do,
```
Car = {}
Car.new = (function(speed, colour, driver)

end)
```
But that's ugly, that's why, with yet again more fancy lua syntax, we can do this.

```
Car = {}

function Car.new(speed, colour, driver)  

end
```
 When we do this, that's the same as setting a variable in the table, but here we're doing it in a cooler way, a way that makes it look that it's actaully a constructor function. Now let's make the actual object out of that.
```
Car = {}

function Car.new(speed, colour, driver)  
   local newCar = {}
   
   newCar.speed = speed or 0
   newCar.colour = colour or "Grey"
   newCar.driver = driver or "No one"

  return newCar
end
```
Now, as I was saying, we are returning the object, as a table. When we construct it, we can choose its properties, make new variables in it, and set those variables to whatever we chose, and those will be our properties. You can see that newCar table,  which is the object that's getting constructed when we call this function. And it'll contain those variables, or call them properties, and if you're wondering why we did those `or`s, because if the speed and colour and driver paramaters weren't put in, which means they will be nil, the variable would be like (var = nil or 0), and in this case it will take 0 instead of the 0, but if the argument were set it will just take that. And also, you can call that
So we can do
```
Car = {}

function Car.new(speed, colour, driver)  
   local newCar = {}
   
   newCar.speed = speed or 0
   newCar.colour = colour or "Grey"
   newCar.driver = driver or "No one"

   return newCar
end

local CarObject = Car.new(15, "Black", "Builderman") 
CarObject.driver = "Builderman's mum"

print(CarObject.speed, CarObject.colour, CarObject.driver)
```
That CarObject variable, is our object, we set it to whatever our constructor function returns! And we can play with it as you can see, no what about the methods, let's do that.

First, a super brief explanation on metatables. A table can have its metatable, just think of that, the way you do that is.
```lua
local table = {}
local metaTable = {}

setmetatable(table, metaTable) --this is giving the table "table" a metatable  called "metaTable"
print(getmetatable(table)) -- this would print metaTable
```
I won't go over why metatables are a thing, but for now keep this basic idea, so, when a table has its own metatable, we can put into that metatable something called a metamethod. There are a lot of these, but the most common on is called `__index` and also is the one we are going to explain. Now, we put this metamethod into our metatable, and it's actually suposed to be a variable, which we set to another table.

```lua
local table = {}
local metaTable = {__index = metaTable} -- we set table to the metatable itself
metaTable.x = 5

print(table.x) --this would actually print 5
```
Now, I'm not gonna go in detail on this, but just keep this idea, you see that `print(table.x)`, you would think that it orints nil because that x variable doesn't exist within "table". But what the script does, check if he that table has that variable, but it doesn't, then it check if that table has a metatable, it does, and then it checks if that metatble has an __index metamethod, and after all that, it will check of the variable x exists in the metatable, get it? So, keep this idea, if that *x* variable doesn't exist within a table, and if it exists in the metatable of that table (if it has one) then, that x variable would exist. That's the information I want you to store. You'll see why later.

Now, remember when I told you to keep in mind that we want the new car object table in the "Car" class table, well, here is why, and also why we're gonna use metatables. It's for making methods, now you see, when we wanna make a function, we don't want to create a new function and insert it to the newCar object table, that would be annoying and we would have to do it each time we create an object, so what about we create that function inside of the Car class table, and like we said early on, take it from there and use it on the object!
Let's do that. We're gonna use metatables now.

```
Car = {}

function Car.new(speed, colour, driver)  
   local newCar = {}
   
   newCar.speed = speed or 0
   newCar.colour = colour or "Grey"
   newCar.driver = driver or "No one"

   return newCar
end                                                

function Car:Boost(increment) 
--this is how we set a function with these ":" guys btw
   self.speed = self.speed + increment
end

```
Okay, we made the function, and that's getting inside of "Car" if you're wondering. Now, I'm sure you are asking what in the heck is that `self`, that's something cool in Lua. That self refers to whatever thing this method is getting used on. In a method that has that *:* format, for example `aPart:Destroy()`, the self here is actually "aPart", and this `self` isn't set in the arguments, it's automaticlly declared within the function, but if there was a function like this, `table.Method(self)` you do have to define that self. So yeah, `:Boost()` exists within the "Car" table, but just think that we are going to use it on something else, we don't have to set that something in the arguments, we just use the function on it, and if we type self inside of that function, it should refer to the object we are using the method on.

 And we are yet again doing it in a weird syntax way, in order to put into the table, and we have a reason for that! as I said, we don't want to create a new Boost function each time and put it inside of the `newCar` table each time we create an object, we want the function to be at the Class, and whenver we create a new object out of a class, we can use functions on that object, taking the function from the class. This is where metatables and the `__index` metamethod comes in, as I said, the use of __index is: so we want the Method to be just in the class "Car" table, and be able to use it from there, so we can make the "Car" class the metatable of any newCar table that was constructed, and have an __index metamethod inside of this metatable, so know any variables that are inside of "Car" would be accessible from the "newCar" table even if those variables don't exist within "newCar". Keep that in your mind! And remeber that when we do `Car:Boost()` is littearly the same as `Car.Boost()`, that :Boost() is actually a variable inside of Car, but with these `:` and not these `.`, a variable that hold a function, that can be used on objects.

```
Car = {}
Car.__index = Car --we put the index variable in, and set it to Car because that is that table we want to take variables from 

function Car.new(speed, colour, driver)  
   local newCar = {}
   setmetatable(newCar, Car) 
   --we make Car the metatable of newCar
   newCar.speed = speed or 0
   newCar.colour = colour or "Grey"
   newCar.driver = driver or "No one"

   return newCar
end                                                

function Car:Boost(increment) 
   self.speed = self.speed + increment
end

```
And like that! We are totally done with this! Let's try it out.

```
Car = {}
Car.__index = Car

function Car.new(speed, colour, driver)  
   local newCar = {}
   setmetatable(newCar, Car) 

   newCar.speed = speed or 0
   newCar.colour = colour or "Grey"
   newCar.driver = driver or "No one"

   return newCar
end                                                

function Car:Boost(increment) 
   self.speed = self.speed + increment
end

local Car1 = Car.new(50, "Blue", "StarmaQ")
print(Car1.speed)
Car1.colour = "Applesauce"
print(Car1.colour, Car1.driver)

Car1:Boost(20)
print(Car1.speed)
```

And we are officially done! I hope I was clear with everything and made things simple. And remember to "never stop lerning".
