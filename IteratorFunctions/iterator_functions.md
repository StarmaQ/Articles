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

Let's start by trying to make a replica of `pairs`. Wait, haven't we already done that with `xpairs`? Well there are some key features that `pairs`, or I should actually say `next`, and we don't. For example, with `next`, if you had a table like this `{1, 2, nil, 3}`, it actually traverses through the whole table ignoring `nil` at index 3 and carrying on later to the 4th index (which is `3`) and stops. With our `iterator` in `xpairs`, we would stop as soon as we return nil, when we get to index 3 it returns nil and stops looping even though there is more ahead. How would we do that? Well since `# 
