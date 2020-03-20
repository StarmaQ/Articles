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

![metatable1|641x500, 100%](upload://eemXC8NwUFFwSLhtw6MPHUz50yh.png)*(Image by @BenSBk)* 

To set a metatable `mt` to a table `t`, you need to use `setmetatable()`, and can use `getmetatable()` to get a table's metatable if you need it.
```
local t = {}
local mt = {}
setmetatable(t, mt)

print(getmetatable(t)) --returns mt, which is basically a table
```
An alternative, since `setmetatable()` returns the table we set the metatable of, we can do
```
local t = setmetatable({}, {})
--where the second table is the metatable, that we will fill with metamethods
```
II. Metamethods
--
Metamethods are the main source of a metatable's powers. They are the *"configurations"* that I mentioned earlier. They are fields we put inside of a metatable, which I'll show you how they work in a second. They are commonly prefixed with a `__` (like `__index`, `__newindex` ect.), and most commonly set to a function (and in some special cases, set to a table or a string, we will cover these cases).

We will start with the `__index` metamethod, which is one of the basic ones. `__index` can be set to a table, or a function. I'm gonna be covering the function first, because I think explaining the table part makes understanding other metamethods harder.
I'm gonna write a piece of code that might be hard to understand at first, but we'll examine what's happening, and break down what's going on in order to understand.

```
local t = setmetatable({}, { 
    __index = function(table, key)
        return key.." does not exist"
    end
})
 
print(t.x)
```

[details="Just to get rid of confusion for beginners"]
As I said, this is the same as 
```
local t = {}
local mt = {
    __index = function(table, key)
        return key.." does not exist"
    end
}
 ```
And if this still looks weird, we're basically putting a function inside of a table. `__index` is being set to a function. We can do something else like
```
local t = {}
local mt = {}
mt.__index = function(table, key)
     return key.." does not exist"
end
```
[/details] 


Normally, `t.x` would be `nil` thus it would print `nil`, because there is no key inside of `t` called `x`, `x` doesn't exist. Although, this is not the case here, what would happen is, it would print `x does not exit`, which is the same message we are returning inside of the function.

So, to keep it short: you can think of **metamethods as events**. An event fires when something happens, a metamethod invokes when something happens to the table its metatable is connected with.

The `__index` metamethod *fires*/invokes when you index a table `t` with a value `x`, where `x` doesn't exist. (Doing t[x] or t.x, when there isn't an x). 

Just like events, when they fire they run the function they're connected to, metamethods run the function they're set to. Yet again, just like events, they give additional information through parameters that you can use, metamethods do that aswell. That's what's going on with the code above, the function is being ran, returning that message, replacing the `nil` that was supposed to be returned.

The `__index` metamethod gives back the table you indexed first, and the key that you indexed with second, as parameters if you wanna call them like that. (in this case, the independant `table` and `key` parameters)

As well, metamethods can return values, just like in the example I gave, we returned a string saying that the key you tried to look for doesn't exist.

After all that, we added a new power to our basic table, the ability to tell the user that a key didn't exist, instead of just giving back nil. Not interesting, but cool.

And just like that, if you understood this, you're able to use almost any metamethod. Just like events, understand how events work in general, makes the rest easy. It's just a matter of asking "when that metamethod fires". The Roblox Dev wiki shows you all the metamethods Roblox has, describing when they fire. I am gonna be covering most of them, even though that's not needed, you can do it yourself.

![image|465x500](upload://cEWP4aXb8f2MPgI8ocIsJni9frg.png) *(image from wiki)*

I recommend you explore the code I wrote more, to get a bigger picture of what's going on. Let me remind you that you're free to do whatever you want inside of that function, you don't necessarily need to return something, or return something logical. Here is a good demonstration

```
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
```
local t = {}
local mt = {__index = {x = 5}}

print(t.x) --actually prints 5
```
It checks if `t` contains `x`, if it doesn't, checks if `t` has a metatable, it has one `mt`, checks if `mt` has a `__index` metamethod, it does, checks if `__index`'s table contains `x`, it does, return that. Basically, `t` and `mt` share the same keys.

Now for a more interesting metamethod, `__newindex`. `__newindex` fires when you try to create a new index that didn't exist. 

III. Operator Overloading
--

Operator overloading is making an operator (`+`, `-`, `*` ect. `==`, `>`, `<` ect.) compatible with more than just one datatype. Meaning, you could do `num + num`, what about doing `string  + string`? Of course here we are interested in tables. Yeah! We can actually add, subtract, multiply or do any sort of arithmetic on them. Here are the metamethods responsible for operator overloading.


![image|690x197, 75%](upload://rqXBrqq1A4Uzhxz96cIlbTBeEOY.png) 
![image|690x142, 75%](upload://lY0oMFNc4L5D7204WhmQfZCKHXJ.png) 

Of course we can put many different metamethods into one metatable, like this
```
local t = {}
local mt = {__add = function(v1, v2) end, __sub = function(v1, v2) end, 
__mul = function(v1, v2) end, __div = function(v1, v2) end}

setmetatable(t, mt)
```

Let's just start with one then fill the rest.
```
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
```
print(5 + t) --this would error
```
Order matters. In the first script, `t` is `v1`, and `5` is `v2`. In the second script, `5` is `v1`, `t` is `v2`, which means I'm doing `#v1`, thus `#5`, which would error. So you need to make a bunch of if statments to watch out from cases like this.

Now what about adding tables? Same thing really. But both tables needs to have the `__add` metamethod. You can't add a table that has an `__add` with one that doesn't.
```
local t1 = {"hi", true}
local t2 = {79, "bye", false}
local mt = {__add = function(v1, v2) return #v1 + #v2 end}

setmetatable(t1, mt)
setmetatable(t2, mt) --both need to have __add, you can see they can share a metatable

print(t1 + t2) --prints 5
```
Two things to point out, order matters here as well, and also if you're wondering the metamethod will only invoke once and not twice. So yeah, you can do this with the other mathematical operations as well.

You can even concatenate (using the `..` operator on strings) on tables, using `__concat`.
```
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
You also got `__lt` (less then), `__le` (less or equal to) and `__eq` (equal) which you can explore yourself. A `__mt` (more then) and `__me` (more or equal to) don't exist, but you can simply invert the usage of the already existing ones, instead of doing `a > b` do `b < a`.

You also got `__unm`, which is basically the inverter operator, like doing `-5`, inverse of `5`
you can do `-table`. For example you can invert all of the table's elements.
