Metatables! Truly an interesting subject. Through my activity in different forums and discord servers, I have seen many people get confused, on what they are. Main reason being, not a super wide collection of resources exist explaining them, and in general the idea of metatables is different and unique for someone who got used to simple notation, such as loops, and if statments. 

**I**. Metatables
--
There isn't really a definition to what a metatable is. It's just that, any table can have a metatable. Stick with that idea. (and in addition, many tables can share the same metatable, a table can have multiple metatables, and a table can be its own metatable). At the end, a metatable is a table itself.

More formally, you can think of a metatable, as **a normal table that holds configurations/settings for another table** that let's you change the behaviour of that other table.

The idea behind metatables is, to make tables a more powerful object! To turn them, from simple data structures, with just a small collection of abilities:
* Storing pairs of keys and values
* Getting values back from keys
* The # operator

into something, with way more tools in the shed, using those configurations:
* All the normal abilities
* Do arithmetic on them (division, addition, subtraction..)
* Compare them
* Call them like functions
* `tostring()` them
* And much more!

![](https://github.com/StarmaQ/Articles/edit/master/Metatables/Imgs/metatable1.png)*(Image by @BenSBk)* 

To set a metatable `mt` to a table `t`, you need to use `setmetatable()`, and can use `getmetatable()` to get a table's metatable if you need it.
```lua
local t = {}
local mt = {}
setmetatable(t, mt)

print(getmetatable(t)) --returns mt, which is basically a table
```
An alternative, since `setmetatable()` returns the table we set the metatable of, we can do
```lua
local t = setmetatable({}, {})
--where the second table is the metatable, that we will fill with metamethods
```
II. Metamethods
--
Metamethods are the main source of a metatable's powers. They are the *"configurations"* that I mentioned earlier. They are fields we put inside of a metatable, which I'll show you how they work in a second. They are commonly prefixed with a `__` (like `__index`, `__newindex` ect.), and most commonly set to a function (and in some special cases, set to a table or a string, we will cover these cases).

We will start with the `__index` metamethod, which is one of the basic ones. `__index` can be set to a table, or a function. I'm gonna be covering the function first, because I think explaining the table part makes understanding other metamethods harder.
I'm gonna write a piece of code that might be hard to understand at first, but we'll examine what's happening, and break down what's going on in order to understand.

```lua
local t = setmetatable({}, { 
    __index = function(table, key)
        return key.." does not exist"
    end
})
 
print(t.x)
```

[details="Just to get rid of confusion for beginners"]
As I said, this is the same as 
```lua
local t = {}
local mt = {
    __index = function(table, key)
        return key.." does not exist"
    end
}
 ```
And if this still looks weird, we're basically putting a function inside of a table. `__index` is being set to a function. We can do something else like
```lua
local t = {}
local mt = {}
mt.__index = function(table, key)
     return key.." does not exist"
end
```
[/details] 


Normally, `t.x` would be `nil` thus it would print `nil`, because there is no key inside of `t` called `x`, `x` doesn't exist. Although, this is not the case here, what would happen is, it would print `x does not exit`, which is the same message we are returning inside of the function.

So, to keep it short: you can think of **metamethods as events**. An event fires when something happens, a metamethod invokes when something happens to the table its metatable is connected with.

The `__index` metamethod *fires*/invokes when you index a table `t` with a value `x`, where `x` doesn't exist. (Doing t[x] or t.x, when there isn't an x in t). 

Just like events, when they fire they run the function they're connected to, metamethods run the function they're set to. Yet again, just like events, they give additional information through parameters that you can use, metamethods do that aswell. 

The `__index` metamethod gives back the table you indexed first, and the key that you indexed with second, as parameters if you wanna call them like that. (in this case, the independant `table` and `key` parameters)

As well, metamethods can return values, just like in the example I gave, we returned a string saying that the key you tried to look for doesn't exist.

After all that, we added a new power to our basic table, the ability to tell the user that a key didn't exist, instead of just giving back nil. Not interesting, but cool.

And just like that, if you understood this, you're able to use almost any metamethod. Just like events, understand how events work in general, makes the rest easy. It's just a matter of asking "when that metamethod fires". The Roblox Dev wiki shows you all the metamethods Roblox has, describing when they fire. I am gonna be covering most of them, even though that's not needed, you can do it yourself.

![image|465x500](upload://cEWP4aXb8f2MPgI8ocIsJni9frg.png) *(image from wiki)*

I recommend you explore the code I wrote more, to get a bigger picture of what's going on. Let me remind you that you're free to do whatever you want inside of that function, you don't necessarily need to return something, or return something logical. Here is a good demonstration

```lua
local adresses = {mike = "manhattan", george = "france"}
local metatable = {
__index = function(t, k)
    print(k.."'s adress isn't found in "..tostring(t)..", creating a place for it")
    t[k] = "N/A"
    return t[k]
end} 
setmetatable(adresses, metatable)

print(adresses.starmaq)
--prints that message with the additional info
--and creates a place for that new adress returning "N/A"
--it's good to point out this also works with numerical indices (adresses[1], [2] ect.)
```

Also, what about the special case where `__index` can be set to a table. Well that doesn't involve any relation with events. When you set `__index` to a table, instead of running the function it's set to when it fires, it looks for the key you're looking for inside of the table `__index` is set to.
```lua
local t = {}
local mt = {__index = {x = 5}}

print(t.x) --actually prints 5
```
It checks if `t` contains `x`, if it doesn't, checks if `t` has a metatable, it has one `mt`, checks if `mt` has a `__index` metamethod, it does, checks if `__index`'s table contains `x`, it does, return that. Basically, `t` and `mt` share the same keys.

Now for a more interesting metamethod, `__newindex`. `__newindex` fires when you try to create a new index that didn't exist before. (Doing t[x] = value or t.x = value, where x didn't exist before in t)
```lua
local t = setmetatable({x = 5, y = 7}, {
     __newindex = function(t, k, value) 
         print("This is read-only table")
     end
})

t.z = 8 --prints that message
```
As you can see, you can come up with a lot of ideas. I just made a read-only table (even though you can change already existing keys). `__newindex` gives back the table, the key, and the value you wanted to set as a third parameter. Also, `__newindex` stops you from setting the value. It doesn't create the new value and run the function, it stops you from creating the function and runs the function.

III. Operator Overloading
--

Operator overloading is making an operator (`+`, `-`, `*` ect. `==`, `>`, `<` ect.) compatible with more than just one datatype. Meaning, you could do `num + num`, what about doing `string  + string`? Of course here we are interested in tables. Yeah! We can actually add, subtract, multiply or do any sort of arithmetic on them. Here are the metamethods responsible for operator overloading.


![](https://github.com/StarmaQ/Articles/edit/master/Metatables/Imgs/metatable2.png)
![](https://github.com/StarmaQ/Articles/edit/master/Metatables/Imgs/metatable3.png)

Of course we can put many different metamethods into one metatable, like this
```lua
local t = {}
local mt = {__add = function(v1, v2) end, __sub = function(v1, v2) end, 
__mul = function(v1, v2) end, __div = function(v1, v2) end}

setmetatable(t, mt)
```

Let's just start with one then fill the rest.
```lua
local t = {46, 35, 38}
local mt = {
     __add = function(v1, v2)
         return #v1 + v2 
     end
}
setmetatable(t, mt)

print(t + 5) --actually prints 8!
```
Pretty amazing right? We can now add table. 
As I said earlier, you can do whatever you want inside of the function, there isn't something exact. Adding tables doesn't really have a rule, it's weird. I came up with my own way of doing it,  by adding `#t` (`#v1`), how many elements are in `t`, with `5` (`v2`). You could've done something else, like looping through `t` (`v1`) and adding all of its elements (46, 35, 38) with `5` (`v2`).

 Note, if I did
```lua
print(5 + t) --this would error
```
Order matters. In the first script, `t` is `v1`, and `5` is `v2`. In the second script, `5` is `v1`, `t` is `v2`, which means I'm doing `#v1`, thus `#5`, which would error. So you need to make a bunch of if statments to watch out from cases like this.

Now what about adding tables? Same thing really. But both tables needs to have the `__add` metamethod. You can't add a table that has an `__add` with one that doesn't.
```lua
local t1 = {"hi", true}
local t2 = {79, "bye", false}
local mt = {__add = function(v1, v2) return #v1 + #v2 end}

setmetatable(t1, mt)
setmetatable(t2, mt) --both need to have __add, you can see they can share a metatable

print(t1 + t2) --prints 5
```
Two things to point out, order matters here as well, and also if you're wondering the metamethod will only invoke once and not twice. So yeah, you can do this with the other mathematical operations as well.

You can even concatenate (using the `..` operator on strings) tables, using `__concat`.
```lua
local t1 = {"hi", true}
local t2 = {79, "bye", false}
local mt = {
    __concat = function(v1, v2)
        local output = {}
        for i, v in pairs(v1) do
            table.insert(output, v)
        end
        for i, v in pairs(v2) do
            table.insert(output, v)
        end
    end
}
setmetatable(t1, mt)
setmetatable(t2, mt) --they gotta have it both as well

local t3 = t1..t2 --we merged t1 and t2 together, as you can see you can get creative
print(unpack(t3)) --t3 contains all of t1 and t2's members
```
You also got `__lt` (less then), `__le` (less or equal to) and `__eq` (equal) which you can explore yourself. A `__mt` (more then) and `__me` (more or equal to) don't exist, but you can access them in a really weird way.

You also got `__unm`, which is basically the inverter operator, like doing `-5`, inverse of `5`
you can do `-table`. For example you can invert all of the table's elements.

IV. Weak tables
--
In this section, we will be talking about `__mode`, a rather unique metamethod. We will be covering a feature that's partially disabled in Roblox, if you're interested.

Before covering weak tables and `__mode`, let's talk about something else, garbage collection. Any language has a garabge collector, which is responsible for getting rid of unwanted and untracked data to prevent memory leaks. Basically, when a lua object (a table, a function, a thread (couroutines) and strings) is overwritten or removed (by setting it to nil), it's technically gone, but it's not freed from the system's memory, it's still there, but it's unreachable.
```lua
local t = {} 
t = nil --now t is unreachable

local str = "hi"
str = "bye" --now hi is lost, it's unreachable
```
For lua's garbage collector, anything unreachable, meaning nothing no longer has a reference to it, is considered garbage, meaning it's a target for the garbage collector, to collect it and get rid of that uneeded *trash data*. The lua garbage collector makes a cycle automatically every once in a while, all though you can manually call `collectgarbage()` to launch a garbage collceting cycle, which will get rid of unreachables. And this is exactly the feature that roblox disables, you can not force a garbage collection, calling `collectgarbage()` will do nothing, but in a normal lua compiler it would.

```lua
local t = {} 
t = nil

local str = "hi"
str = "bye" 

collectgarbage() --garbage cleared!
```
Note that, I chose a string and a table because those are lua objects that get collected, litterals like numbers and booleans don't get garbage collected, because they don't need to. Also, we can print `collectgarbage("count")` before and after the `collectgarbage()`, and you'll see that the number decreased. This returns how much memory is used by lua in KB, and funny enough lua has this feature enabled. More [info](http://lua-users.org/wiki/GarbageCollectionTutorial) on garbage collection can be found here.

Now, let's take a more complicated example
```lua
local val = {}
local t = {x = val}

val = nil

collectgarbage() --you'd expect {} to be collected

for i, v in pairs(t) do
    print(v) --prints the table
end
```
In this code, technically the table `val` contains is unreachable, we set val to nil, and `garbagecollect()`'d. Although it's still not removed, not just from memory, but from the program itself, because it still exists inside of `t`, it's printed in the `pairs` loop. Know why?
As I said, an object is considered garbage if it has 0 references, but that `{}` still has a reference, it's the table containing it, it's referenced by that, so it's not considered garbage. That could be a problem. Here is where weak tables come in.

A weak table is a table containing *weak references* (either weak keys, or  weak values, or both). If it's a weak reference, it will not prevent the garbage collection cycle from collecting it, if it has no other reference then the weak table containing it.

`__mode` is responsible for making a table weak. It's the special case that I mentioned at the beginning that can be set to a string. The string can either be "v", meaning table has weak values, or "k", meaning table has weak keys. 

`"v"` will let the cycle collect the key/value pair if 
the value only has one reference and that reference is the containing table. 

`"k"` will let the cycle collect the key/value pair if the key only has one reference and that reference is the containing table.

```lua
local val = {}
local t = {x = val}

local mt = {__mode = "v"}
setmetatable(t, mt)

val = nil --now {} only has one reference, which is t

collectgarbage() 

for i, v in pairs(t) do
    print(v) --doesn't print anything, {} and it's corresponding key x are removed!
end
```
I hope you understood how it works
What if you wanted weak keys? The key would need to be the `{}`

```lua
local val = {}
local t = {[val] = true}

local mt = {__mode = "k"}
setmetatable(t, mt)

val = nil --now {} only has one reference, which is t

collectgarbage() 

for i, v in pairs(t) do
    print(v) --doesn't print anything, {} and it's corresponding value true are removed!
end
```
Let me introduce an even more complicated example

```lua
local t1, t2, t3, t4 = {}, {}, {}, {} --4 strong references for all tables
local maintab = {t1, t2} -- strong references to t1 and t2
local weaktab = setmetatable({t1, t2, t3, t4}, {__mode = "v"}) --weak references for all tables

t1, t2, t3, t4 = nil, nil, nil, nil --no more strong references for all tables

print(#maintab, #weaktab) --2 4

collectgarbage() --t3 and t4 get collected

print(#maintab, #weaktab) --2 2
```
![](https://github.com/StarmaQ/Articles/edit/master/Metatables/Imgs/metatable4.png)

And just wanted to mention this since it has a relation with garbage collection, there is a `__gc` metamethod, which is supposed to invoke when a table is garbage collected (the table and not a weak key/value inside of it). Although this metamethod is disabled in roblox as well.

V. Rawset, Rawget, Rawequal
--

`rawset()`, `rawget()` and `rawequal()` all have the same idea. To put it simply, they're supposed to do something without invoking a certain metamethod.

 `rawset(t, x, v)` sets a key `x` with the value `v` inside of `t`. If x didn't exist before, where it would normally invoke `__newindex` if it was present, `rawset()` prevents `__newindex` from invoking. 

`rawget(t, x)` will return the key `x` from table `t`. If x didn't exist, `rawget()` prevents `__index` from invoking. 

`rawequal(t1, t2)` compares if table `t1` and `t2` are equal without invoking `__eq`, this can be used to check if two tables are equal the normal way.

There are a lot of cases where you find yourself not wanting to do one of these three actions but don't wanna invoke a metamethod. 
The wiki gives a really good example. Let's say you had a table, and each time you indexed something that didn't exist, you create it. The problem is, this table has a `__newindex` as well. Remember that `__newindex` stops you from setting a new value, it will not let you create that new value. In fact it will even cause an error, a C-Stack overflow, which happens when a function is called excessivly, it's `__index`'s function, being called a lot of times trying to set the value but `__newindex` is not letting it. We are not using `__newindex` on anything, we can technically remove it, but let's just say we are going to use it for something else. What do we need to do? Well, use `rawset(t, x, v)` instead of doing `t[x] = v`, which will prevent `__newindex` from invoking.

```lua
local t = setmetatable({}, {
    __index = function(t, i)
        rawset(t, i, true) --there you go, just chose true as a placeholder value
        return t[i] 
   end,
   __newindex = function(t, i, v)

   end
})
print(t[1]) -- prints true
```
(*code from wiki*)

VI. Strings are Tables
--

Well not really, but, suprisingly, strings can have metatables as well! Kind of weird, but it's logical I guess, considering that in binary, strings are just an array of characters. You don't have to `setmetatable()` a string's metatable, a string already has a metatable, you have to `getmetatable()` it. Really interesting in my opinion.
```lua
local str = "starmaq"
local mt = getmetatable(str)
```
Now, a problem if I print the metatable
```lua
print(mt)
```
It prints `"The metatable is locked"`. And attempting to add any metamethod to it, will throw an error.
```lua
mt.__index = function() end
 ```
Well darn it, this is happening because of the `__metatable` metamethod. This metamethod prevents you from getting a table's metatable, returning something else instead. Also this metamathod will throw an error if you try to `setmetatable()` another metatable.
```lua
local t = {}
local mt = {__metatable = function() return "This metatable is locked" end}

print(getmetatable(t)) --prints the message
setmetatable(t, {}) --errors
```
Which is sad, but outside of Roblox, in a normal lua compiler, you can actually get the metatable's table, and add metamethods to it. So let's just see what we can do with that. For example, in some languages like C and C++ you can index strings, meaning if you had a string `str` equal to `"good"`, doing `str[4]` will give back `d`. In lua this isn't a thing, you'd have to do `string.sub(str, 4, 4)`, but with metatables, we can create a way to index strings.
```lua
local str = "starmaq"
local mt = getmetatable(str)
mt.__index = function(s, i) return string.sub(s, i, i) end

print(str[5]) --prints m, correct
```
What's even crazier, all strings, wether declared already or not, share the same metatable, meaning if I indexed any other string, it would as well.
```lua
local str2 = "goodbye"
print(str2[6]) --y
```
And you can come up with a lot of create stuff to do. 

There is also something else that can have a metatable, `userdata`. A userdata is an empty allocated piece of memory with a given size. Roblox developers don't have access to create an empty userdata, because it involves a lot of [lua C api](https://www.lua.org/pil/24.html) ([info](http://www.lua.org/pil/28.1.html) on userdata if you're interested) stuff which is obviously not accessible in roblox. Although, Roblox instances (parts, scripts ect.) and some built-in objects (CFrames, Vector3s ect.) are all userdata, and all have a metatable, although it's locked.
```lua
local part = Instance.new("Part")
local cf = CFrame.new()
local v3 = CFrame.new()

print(getmetatable(part)) --"The metatable is locked"
print(getmetatable(cf)) --"The metatable is locked"
print(getmetatable(v3)) --"The metatable is locked"
```
VII. About exploiting
--
Exploiting has a big relation with metatables. This section will link between `V` and `VI`.

Often, I find people asking: "Is making an if statment checking if a player's speed is big, if so kick him a good anti-speed exploit".
```lua
if character.Humanoid.WalkSpeed > 16 then
     player:Kick("Yeet'd out of the universe")
end
```
The answer is no. Because exploiters can change what the WalkSpeed shows up as. His walkspeed can be `10000`, but scripts view it as `16`. How? Well, as I said, Roblox instances (humanoid in this case) have a metatable, using `__index`, the expoiter can check when a property is indexed (doing `Humanoid.WalkSpeed` for example) and if so return 16, instead of letting Roblox return the actual walkspeed. But also, I said Roblox instances' metatable is locked, you can't add metamethods to it, well, most exploits have the lua debug library, which contains a function that can get a metatable without invoking `__metatable`, which is `debug.getmetatable`, otherwise called `getrawmetatable()` (get**raw**metatable, just like the other raw functions that do something withou invoking a metamethods). And with this combination, you can trick scripts, and sometimes it might ruin sanity checks in the client side.

---------

