
In this article we'll be covering an important [chapter](https://www.lua.org/pil/7.1.html) of the lua pil, iterator functions.
You might've encountered this term before, when mentioning either `pairs` or `ipairs`.


`I. Introduction`
--
First of all, I want you to change the way you view a generic for loop. A generic for loop is the `for ... in x` loop. Most of the time, you'd find yourself writing this.
```lua
for i, v in pairs(t) do

end
```
where `t` is the table you wanna loop through (or in otherwords, *iterate* through). Most beginners learn this and just think it's a solid set of keywords including `pairs` that can't be changed (e.g. calling this last snippet of code an `in pairs` loop), and same thing when they encounter `ipairs`. Would you be suprised if I tell you that `pairs` (and `ipairs`) is just a function, and that you can put any other function you made instead of it. Earlier I described the generic for loop as 
```lua
for ... in x do

end
```
I think this is a brilliant way to think about it. `...` and `x` are the only independant parts that can be changed. `x` is the function (and to not cause confusion, it's not the iterator function here, we'll talk about that later) that takes the table to iterate through as input. `...` are the pieces of info that the function gives back (it's not actually the function that gives those pieces of info, it's the iterator function that does, again we'll talk about it later), for example `pairs` gives back the current value's index (commonly called the variable `i`)  and the current value (commonly called the variable `v`), you can actually make a function that gives back more than 2 pieces of info, or even less!

Now let's talk about how you would write a function like these ones that can be used in a generic for loop. 
Something that you might've knew before is `next`, which is also another function. `pairs` actually returns `next`, `next` is the iterator function here.

Ok so wait, let's wrap it up. The function `x` that we want to write needs to return a function, and not any function, an iterator function. An iterator function determines the next value to be returned from the inputted table given the previous index, you can see that's actually how `next` works, it takes two inputs, the table being iterated and the current and the previous index, if I wanted the 3rd index, I do `next({1,3,4,5}, 2)` which is basically saying I was previously at the 2nd index get me the value from the next index. And that's how the generic for loop works, it uses the iterator function returned from `x`, starting with 0 (it starts with 0 so at the first iteration the determined value is 1, I hope that makes sense) and keeps on incrementing that value until the iterator function returns nil, because technically if we had a table `{1,2,3,4}` and we said I was previously at 4, it will give the 5th value which doesn't exist, in otherwords it's nil, thus nil is returned and the loop stops. As you can see we just provide an iterator function and the generic for loop does the repeating job.
Also, if the returned function is called an iterator function, then what is `x` called? It's actually called a *factory*, in lua, a factory is a function that returns a function, just like in our case. You'll see me use this term a lot.

Let's write some code to see what's happening. I'm gonna implement something simple to loop through a table.
```lua
local function xpairs(t) --I called the factory xpairs
    local idx = 0
    local function iterator()
        idx = idx + 1
        return t[idx]
    end
    return iterator
end
```
You can see exactly what we talked about put into action. The factory is called `xpairs` and the iterator function it returns is called `iterator`. I keep a variable called `idx`, this is our *state*, it's used to keep track of the previous index, you can see at the start `idx` is 0 and not 1, because `iterator` increments before returning the value, so at the first iteration the index is 0+1 thus 1. The way `iterator` is written is pretty straight forward, it increments the previous index by 1, and returns whatever value is at that index.

```lua
for v in xpairs({"hi",true,3,4}) do
    print(v) -- actually prints the elements of the table sequently
end
```
`v` is the current element returned by `iterator`, you can see here we only have one piece of info which is the current value, unlike `next` which returns the current index and its value. If I wanted to do that, I would replace the return line by `return idx,t[idx]` and additionally check if we hit the table's length yet (e.g. `idx == #t`) because `t[idx]` would be nil if we're out but `idx` is gonna be always an increasing number thus not only nil is returned and the loop keeps on going.

`II. Iterator examples`
--
Now that we know how to properly write iterators, we can write even more iterators!

Let's start by trying to make a replica of `pairs`. Wait, haven't we already done that with `xpairs`? Well there are some key features that `pairs`, or I should actually say `next`, and we don't. For example, with `next`, if you had a table like this `{1, 2, nil, 3}`, it actually traverses through the whole table ignoring `nil` at index 3 and carrying on later to the 4th index (which is `3`) and stops. With our `iterator` in `xpairs`, we would stop as soon as we return nil, when we get to index 3 it returns nil and stops looping even though there is more ahead. How would we do that? Well since `#{1,2,nil,3}` is actually `4` and not `3`, we can simply check if the current value is nil and we still haven't hit the length of the table yet (e.g. `idx` ~= `#t`), if so, we increment `idx` yet again, until there is no nil and we hit the table's length.
```lua
local function xpairs(t) --I called the factory xpairs
    local idx = 0
    local function iterator()
        idx = idx + 1
        while t[idx] == nil and idx ~= #t do --as long as the value is nil and we're not done
          idx = idx + 1 --keep on adding one, this while loop will stop as soon as we hit a non-nil value 
        end
        return t[idx]
    end
    return iterator
end
```
And you'll see that it works! What about `keys`? `next` can traverse the dictionarry part of a table, how would we do that? Well, unfortunately, we can't. There isn't really a way to get back the keys of a table in plain lua. How does `next` do it then? Let me remind you that any gloabl lua function (e.g. `print`, `unpack`, `pairs`...) is written in the C-side of lua, meaning it's written in the C language, which means they might have stuff that we don't have access to in lua.

What if I wanted to implement `ipairs`? Well funny enough the first `xpairs` we wrote does exactly what `ipairs` does! `ipairs` will iterate through only the array part of the table (meaning the values with numerical indices) and ignore the dictionarry part (keys), which is also what we're not doing. Also, `ipairs` stops as soon as it hits a nil value, even if there is more ahead, which is also what we were doing. `ipairs` doesn't return `next`, it returns a different iterator, which is obvious since as you can see it has a different behaviour. We don't really know the name of the iterator that it returns.

Let's try implementing more stuff! 

Let's make an iterator that iterates through every character in a string.
```lua
local function spairs(str) 
  local idx = 0 
  local function iterator()
    idx = idx + 1
    if idx <= #str then --as long as we didn't hit the string's length, if we did then the iterator will return nothing, in otherwords return nil and the loop stops
      return idx, string.sub(str, idx, idx) --this is a way to return a certain character of a string, I hope you understand it
    end
  end
  return iterator
end

for i, char in spairs("starmaq101") do
  print(i, char)
end
```

`string.gmatch` is a factory in fact, and it returns an iterator which iterates through every matching string with the pattern you gave. [Info](https://devforum.roblox.com/t/how-do-i-use-string-gmatch/313386)
```lua
for match in string.gmatch("hi hiya hiyo", "hi") do

end
```
How would we create one? Well very simple. Utilising the third argument of `string.match`, which is from where to start searching for matches, we can keep a state variable just like `idx`, we would check the first time for any matches with the given pattern, if one exists we would keep track of where that match ended, and return it, and keep on searching depending on the state variable.
```lua
local function gmatch(str, pattern) --you can pass more than a table
  local last = 1 --this is our state, from where we should search
  local function iterator()
    local match = string.match(str, pattern, last) --this is the current match
    if match then --if a match existed, then we'll return it
        last = select(2,string.find(str, match, last))+1 --this is how I determine the next position to search from, string.finding where the current match using the previous last as the third argument, string.find returns two things, the start position of the found match and the end position as the second reutnred value, I use `select` to select the returned value I want, which is the second, hence I do select(2, the two values string.find returns), and of course I add 1 to it so we start searching after it
        return match
    end
  end
  return iterator
end

for match in gmatch("ghi, hi", "%l+") do --%l+ is a string patterns, it's basically saying grab each set of letters, which are ghi and hi
  print(match)
end
```

And you can get creative with this however you want! What if I wanted to make a an iterator which only goes through string values of a table
```lua
local function OnlyStrings(t) 
  local idx = 0
  local function iterator()
    idx = idx + 1
    while type(t[idx]) ~= "string" do
      idx = idx + 1
    end
    return t[idx]
  end
  return iterator
end

for v in OnlyStrings({2,"hi",true,"hgf","kno"}) do
    print(v)
end
```
What about an interesting iterator
```lua
local GetProperties(obj)
  local properties = {"Name","Anchored", "Transparency"} --keep a list of the properties that you wanna include when looping
  local idx = 0 
  
  local function iterator()
    idx = idx + 1
    local property = properties[idx] --the current property
    return property, obj[property] --return the property's name and the property's value, obj[property] is basically the same as obj.property (e.g. obj.Transparency can be written obj["Tansparency"])
  end
  return iterator
end

for property, value in GetProperties(workspace.Part) do
  print(property, value)
end
```
Anyways, let's continue!

`III. Stateless iterators`
--
This is going to be the most important section, so buckle up.

I'm gonna bring up something interesting, let's try printing what pairs returns.
```lua
print(pairs({1,2,3,4}))
```
And the result is
```
function: 0x1016460 table: 0x101c350 nil
```
Wait.. It returns three things? Did I lie to you this whole time by telling you that it returns an iterator function and just that? 

Well, this whole time we were using **stateful** iterators. Stateful iterators are iterators that keep their state. What does that mean? It's the `idx` variable we always used. With stateful iterators, you keep your state internally, you're the one who takes care of it by creating it and incrementing it. With stateless iterators, you don't keep your state, it's given to you. Given by who? Well the generic for loop, but we'll talk about that later. Let's demonstrate what I mean.
I'm gonna define a simple factory and iterator function. I'm not gonna use them in a for loop, I'm just gonna use the iterator function returned manually to see its behaviour.

```lua
local function xpairs(t) 
    local idx = 0
    local function iterator()
        idx = idx + 1
        return t[idx]
    end
    return iterator
end

local iter = xpairs({1,2,3,4})
print(iter()) --1
print(iter()) --2
print(iter()) --3
```
As you see, this is a stateful iterator, it keeps its state internally. Whenever we call it we don't need to pass an argument or anything, it just knows what value to return next because it's the one keeping the state.

I think I made it clear earlier that `pairs` is -oh wait- `next` is a stateless iterator. Remember at the start, `next` needs to get passed the previous index, meaning the state, as a second argument. It's statless! It doesn't save the state, it's given to it. 

Ok so we just talked about all this theoretically, let's write actual code. I'm gonna forget about `pairs` because it's a bad example, I'm gonna write my own factory with a stateless iterator. As we've seen with `pairs`, a factory with a stateless iterator returns three things: the stateless iterator itself, the *invariant* which is basically the inputted table to iterate through (the table won't be affected or changed which is why it's called the invariant) and the *control variable* which is technically speaking our state, at first we need to return the initial starting control variable, basically the starting value for the state which in most cases we covered is 0. In our factory, we need to return these three things for the generic for loop to use. In return, each iteration the stateless iterator gets passed the invariant and previous control variable as arguments (exactly why it's stateless) in order to determine the next value, increment the control variable, and, this is important, it has to return the incremented control variable which will be passed as the `control` argument in the next iteration and the current value as a second value, which means it is essential to return the current index/state before any other value. And just like stateful it will keep on looping until the iterator returns nil. Let's re-write our `xpairs` so it returns a stateless iterators.

```lua
local function xpairs(t)
  local function iterator(invariant, control) --each iteration, the table and the previous control variable are passed as arguments
    control = control + 1 --we increment the control variable each time, at the first iteration the control variable will be 0, we increment it so it becomes 1 use it and return it, so in the next iteration we get passed 1 increment it again so it's 2 and so on.
    if control <= #invariant then --we have to add this now beacuse we are returning the index as I explained at the start
        return control, invariant[control] --we return the current index so it's passed again in the next iteration and the pieces of info which is the value in this case
    end
  end
  return iterator, t, 0 
end

for v in xpairs({1,2,3,4}) do
  print(v) -- actually prints the elements of the table sequently
end
```
Fascinating!
If we were to break down what's happening, the factory `xpairs` first returns the invariant which is `{1,2,3,4}` and initial control variable which is 0, so `{1,2,3,4}` and `0` are passed to `iterator`, iterator increments control variable, returns and returns the current value, and the next iteration the incremented control variable returned from the previous iteration is passed again which is now 1, it's incremented, returned, and you get the picture.

When I said the stateful version of `xpairs` is a replica of `ipairs` I kind of lied because `ipairs` returns a stateless iterator just like `pairs`. The above code is actually how `ipairs` is written. `string.gmatch` for example returns a stateful iterator. How do I know that? Well if you printed what it returns you can see it just returns a function and nothing else.

Sometimes you'd see people writing something fancy like this

```lua
for i, v in next, {1,2,3,4}, nil do
  
end
```
These are really just the values that `pairs({1,2,3,4})` would've returned, but instead of calling pairs to get those we write them straight away, it's just some way to pretend to be like an epic scripter and confuse beginners. Note that the `, nil` could've been omitted. `pairs` is really just written like this, `next` does the juicy stuff.
```lua
local function pairs(t)
    return next, t, nil
end
```
Also don't you find it confusing that `pairs` returns nil as an initial control variable? That's why I said it was a bad example. Well `pairs` is written in the C-side as I said so we can't really know what's happening. But logically, it does this so it can make looping through keys and numerical indices at the same time easy or something.

Also, what about stateful iterators? When a factory returns only a stateful iterator doesn't that disrespect the fact that the `in x do` part takes three values? Well really, if it's not returning anything for those two values, it's kind of like returning nil, so basically nil and nil are being passed to the iterator function, and since we are not using them anyways it's not a problem.

So, which is better to use, a stateful iterator or a stateless iterator? Well use which one you find fitting. It's a choice really. Personally I find stateless iterators cooler due to the notion of being passed the previous index. The only disadvantage to stateless iterators, as I said earlier, you are forced to return an index (state) first along with a value, if you wanted to make an iterator that only returns the value and not the index well you have to use statefuls. 

Anywho! Let's move on and try to re-write some of the previous iterators we wrote earlier to transform them into stateless ones. The loop through a string one.
```lua
local function spairs(str)
  local function iterator(inva, ctrl)
    ctrl = ctrl + 1 
    if ctrl <= #inva then
      return ctrl, string.sub(inva,ctrl,ctrl)
    end
  end
  return iterator, str, 0 
end

for i, char in spairs("starmaq101") do
  print(i, char)
end
```

The `OnlyStrings` one
```lua
local function OnlyStrings(t) 
  local function iterator(inva, ctrl)
    ctrl = ctrl + 1
    while type(t[ctrl]) ~= "string" do
      ctrl = ctrl + 1
    end
    return ctrl, t[ctrl]
  end
  return iterator, t, 0
end

for i, v in OnlyStrings({2,"hi",true,"hgf","kno"}) do
    print(i, v)
end
``` 
For practice try re-writing some of these.

`IV. Iterators with complex state`
--
With stateless iterators, you can only pass two things as an argument to the iterator which are the invariant and the control variable. What if you wanted to pass more info? For example let's say you have an iterator which will loop through a table and stop until it's done iterating through all the elements or it iterated through 4 odd numbers that were inside of that table. You need to keep a state to keep track of how many odds there have been. Well we can do what we do with stateful iterators and store that state within the factory (an upvalue would be a better term).
```lua
local function LoopUntil4Odds(t) 
  local odds = 0 
  
  local function iterator(inva, ctrl)
    ctrl = ctrl + 1 
    
    if odds ==4 then
      return 
    end 
    
    if ctrl <= #inva then 
      if inva[ctrl]%2 ~= 0 then --if it's odd
        odds = odds + 1
      end
      return ctrl, inva[ctrl], odds --additionally I return how many odds there are each time
    end
  end
  return iterator, t, 0
end 
```
But we don't wanna do that, there is a mix of statefulness and statelessness in there, we want to be a fully stateless iterator.

Well, I hope you realise that the invariant and control variable arguments that are passed can be anything, they don't need to be precisly a table and a number. Using that fact, can we pack the invariant and control variable into one thing, say a dictionarry, so it's like `{inva = t, ctrl = 0}`, this dictionarry will be returned by the factory instead of the invariant, and nil is returned instead of the control variable. That dictionarry will be passed to the iterator as an argument instead of the invariant. Let's see what I'm talking about.
```lua
local function xpairs(t)
  local function iterator(dict) --dict is what's in the invariant's place which is the dictionarry
    dict.ctrl = dict.ctrl + 1 
    if dict.ctrl <= #dict.inva then 
        return dict.ctrl, dict.inva[dict.ctrl]
    end
  end
  return iterator, {inva = t, ctrl = 0}, nil --the initial values are put into a dictionarry, note that the ", nil" can be omitted
end
```
As you can see, `{inva = t, ctrl = 0}` is gonna be passed as an invariant each time, and each iteration we increment the ctrl key by 1, and since the invariant doesn't change there is no problem. This is actually a way to bypass the fact that you need to return an index with a stateless iterator.
Remember that the invariant and the control variable are both considered states, here instead of having two seperate states, we have one complex one.

We can definitely pack more info into that dictionarry. We can store more states into it, like the `odds` state. It's initial value is gonna be 0 of course.

```lua
local function LoopUntil4Odds(t) 
  local function iterator(dict)
    dict.ctrl = dict.ctrl + 1 
    
    if dict.odds == 4 then
      return 
    end 
    
    if dict.ctrl <= #dict.inva then 
      if dict.inva[dict.ctrl]%2 ~= 0 then
        dict.odds = dict.odds + 1
      end
      return dict.ctrl, dict.inva[dict.ctrl], dict.odds
    end
  end
  return iterator, {inva = t, ctrl = 0, odds = 0}, nil
end

for i, v, odds in LoopUntil4Odds({1,2,3,4,5,6,7,8,9}) do 
  print(i, v, odds)
end
```

`V. True iterators` 
--
Isn't it weird that we call iterator functions *iterators* even though they aren't the ones doing the iteration, the generic for loop does . The iterator function just determines what value to return next, the generic for loop uses it to do the iteration. That's why the lua PIL prefers to give the iterator name to the generic for loop. What would we name the previously-named iterator function then? Well the lua PIL likes to call them *generators*, because they generate the next value.

Did you know that at a certain point in lua generic for loops didn't exist yet? You had to use `table.foreach` (`table.foreachi` exists as well which is equivilant to `ipairs`) instead. Essentially, it takes two parameters, the table to iterate through, and a function to apply to each element. So if you had something arbitrary like this in the modern lua
```lua 
for i, v in pairs(t) do --where t is some table
  if v > 10 then 
    print(tostring(v).." is greater than 10)
  else
    print(tostring(v).." is less than 10)
  end
end
```
This almost looks like that the body of the for loop is a function where each element is passed as an argument to that function each time. If I were to write this using `table.foreach`, I would do this
```lua
local function f(v) --v is the elemet from the table each time
  if v > 10 then 
    print(tostring(v).." is greater than 10)
  else
    print(tostring(v).." is less than 10)
  end
end

table.foreach(t, f) --where t is some table
```

`table.foreach` does the iteration on its own, it doesn't need a for loop to do so. Cool right? For that reason we call `table.foreach` and `table.foreachi` are called *true iterators*, they are actual iterators that do the iteration on their own, unlike the iterators we have been talking about this whole time that are just plugged in a generic for loop.

----

That's it! I hope you found this article informative (without doubt it is) and as usual, have a wonderful day!
