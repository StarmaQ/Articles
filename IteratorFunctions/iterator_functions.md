
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

Ok so wait, let's wrap it up. 
