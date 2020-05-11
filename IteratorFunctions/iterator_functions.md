1
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
    print(v) -- actually prints the elements of the table 
end
```
`v` is the current element returned by `iterator`, you can see here we only have one piece of info which is the current value, unlike `next` which returns the current index and its value. If I wanted to do that, I would replace the return line by `return idx,t[idx]`.

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
local function gmatch(str, pattern)
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

