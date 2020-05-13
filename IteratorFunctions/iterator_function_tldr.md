Basically, `pairs` and `ipairs` are called factories, and they return something called an *iterator function*. An iterator function is 
used to determine the next value to return. `pairs` returns `next`, it's the one used by the generic for loop to determine the next value each time.

```lua
local function xpairs(t)
  local idx = 0

  local function iterator() --the iterator function to be returned
    idx = idx + 1 --we increment the idx each 
    if idx <= #t then
      return idx, t[idx] --these are the pieces of info returned, the ones commonly denoted as i, v, you can have as many pieces of info returned as you want
    end
  end

  return iterator
end
```
You can use it like this
```lua
for i, v in xpairs({1,2,3,4}) do
  print(i, v)
end
```
These iterators are *stateful* beacuse they keep their state, what is the state? Well it's the variable keeping track where we are currently which in our case is `idx`.
You also got *stateless* iterators, these are iterator that don't keep track of their state. It's given to them by the generic for loop. 
Factories with stateless iterators return 3 things: the iterator itself, the invariant which is the table to be iterated over, and an initial control variable,
which is pretty much the state. Each iteration the stateless iterator gets passed the invariant and the previous control variable as arguments, it increments the control variable, uses it, and return the incremented control variable as a first value along with any other piece of info.
That returned incremented control variable is passed as an argument with the invariant again in the next iteration, and so on.
```lua
local function xpairs(t)
  local function iterator(inva, ctrl) --these are the passed arguments, during the first iteration they would be t and 0, when incremented and return t and 1 are passed ect.
    ctrl = ctrl + 1 --increment 

    if ctrl <= #inva then
      return ctrl, inva[ctrl] --ctrl is gonna be the control variable in the next iteration
    end
  end
  return iterator, t, 0 --as you can see the values here, t and 0 are later passed as argument to the iterator during the first iteration
end
