Two articles have already covered this topic ([link](https://devforum.roblox.com/t/wrapping-with-metatables-or-how-to-alter-the-functionality-of-roblox-objects-without-touching-them/221611) and [link](https://devforum.roblox.com/t/how-to-wrap-roblox-instances-to-allow-for-custom-properties/276055)), and they're both good! But I wanted to approach this idea in my own way. A way that would feel nicer for beginners, especially those that have learned about metatables, and really couldn't get their heads around how they'd use them. Which is why might need a good bit of [knowledge](https://devforum.roblox.com/t/all-you-need-to-know-about-metatables-and-metamethods/503259) about metatables and various of bits of object-oriented programming. Also, I'm gonna be digging deep to talk about more stuff.

----
First of all, what's *wrapping*. Well essentially, it's using something already pre-built and  adding more features to it. For example, if I wanted to wrap `math.random`, I could make it so our wrapped version will also generate random numbers with random decimal place (up to 5 decimal places), if a third argument is passed as true, which is not something that `math.random` does.
```
local function math.random2(min, max, decimal)
    if decimal then
        return math.random(min*10000, max*10000)/10000
    else
        return math.random(min, max)
    end
end
```
As you can see, we're using `math.random` internally, and adding more stuff so we have a new more advanced function, `math.random2`. Another example would `DataStore2`, which is a wrapper for the `DataStore` service. Intrenally, it's littearly just using `DataStore`, but doing more to make it better.

But, in our case, we're gonna be wrapping objects, Roblox instances. We're gonna add more properties to them, more methods, maybe even events. How? Well, let's dive in.

When you're accessing an instance's property, you're in reality just indexing it, the same way you'd index a table. `Part.Transparency` is like having a key called `Transparency` storing a value describing the transparency value of that part. Instances aren't really tables, they're *userdata*s, as I covered before, a userdata is essentially a raw piece of data of an arbitrary size. Roblox is fully made using C++, the engine, the API meaning objects and all that, custom globals like `warn` and `wait`, they're all written in that language. This piece of data is filled with information in the C++ side. And if you're wondering and happen to know that lua is supposed to be embedded into C, how is Roblox embedding lua into C++? Well, because you [can](https://stackoverflow.com/questions/17448014/how-to-use-c-code-in-c) run C code into C++. 

Ok, so, we know that `userdata`s are indexed like you would index a table. We can use this facility to make wrapping objects an implementable thing. How? Well, the same way you'd implement an object within the mindset of OOP. We will have an object with properties and methods, those properties and methods are the additional ones, in order to include the original properties and methods of the original object we make a metatable for the object wrapped object with the additional features with an `__index` set to the original object. Wait, the original object is an instance, a `userdata`, how can we set `__index` (which is supposed to be set to a table) to that? Well we can. This concept is called *duck typing*, the rule says "if it quacks like a duck, and looks like a duck, it's a duck", `userdata`s can be indexed like tables, they technically deserve to be binned to `__index`.

Let's demonstrate what I just said. I will be making an implementation of [IntConstrainedValue](https://developer.roblox.com/en-us/api-reference/class/IntConstrainedValue)s, these are deprecated object values that work almost like `IntValues`, but will also clamp the value just like `math.clamp` does. If `.Value` property is greater than `.MaxValue` it becomes the value of `.MaxValue`, and same for `.MinValue`, if it's less. 
```
local IntConstrainedValue = {}

function IntConstrainedValue.new(value, min, max)    
    local IntValue = Instance.new("IntValue")
    IntValue.Value = value

    local object = {MinValue = min or 0, MaxValue = max or 10}

    setmetatable(object, {__index = IntValue}) --the magic 

    return object
end



local object = IntConstrainedValue.new(5, 8, 10)
print(object.Value, object.MaxValue, object.MinValue) --We are able to access all three properties!
```
We create the original object to wrap `IntValue`, set its value to whatever we chose. Then we create `object` which is going to hold the special properties and method (we haven't added methods yet, made `0` and `10` as default values. Then the most important part, set the `object`'s metatable to a  table with an `__index` pointing to `IntValue`. What happens is, if we reference a property that doesn't exist in `object` we get redirected to `IntValue`. `object.Value` is provided with `IntValue`, `object.MaxValue` and `object.MinValue` are both provided with `object`. We just wrapped this object, added more features to it. Some people would like to call `object` the *interface*, an interface is basically like a remote, it has buttons and let's you interact with the device easily. In this case, that's what the `object` is, we give it input, which happens when we index it, and it makes the job easier for us, depending on our input it gives us back the property we want and we don't really have to care what's going on inside. Just like a TV remote, we click the button and something happens what's happening  is abstracted away from us.

![interface|690x439, 100%](upload://vEQeMKNEdLB8H89Jcw1nlhil3Pe.png)   

So let's do more stuff. We're missing the whole point of IntConstrainedValues, we're not clamping the `.Value`. Let's do that.

```
local IntConstrainedValue = {}

function IntConstrainedValue.new(value, min, max)    
    local IntValue = Instance.new("IntValue")
    IntValue.Value = (value>max and max) or (value<min and min) or value --ternary magic

    local object = {MinValue = min or 0, MaxValue = max or 10}

    setmetatable(object, {__index = IntValue}) 
    return object
end



local object = IntConstrainedValue.new(5, 8, 10)
print(object.Value, object.MaxValue, object.MinValue) 
```
We need to make it so we can edit the values as well. We need it to work for both the custom and original properties. If you `object.MaxValue` = 5, it should change the custom object and `object.Value = 6` should change the `IntVaue`'s property. We can do that with `__newindex`.

```
local IntConstrainedValue = {}

function IntConstrainedValue.new(value, min, max)    
    local IntValue = Instance.new("IntValue")
    IntValue.Value = (value>max and max) or (value<min and min) or value 

    local object = {MinValue = min or 0, MaxValue = max or 10}

    setmetatable(object, {__index = IntValue, --mind the weird syntax!
        __newindex = function(_, property, value) 
            IntValue[property] = (value>max and max) or (value<min and min) or value 
            --remember how properties are just indexed, we can do IntValue[property]
            --where property is the key, or in this case property, that we wanted to access
            --also remember how we need to clamp the value
        end
    }) 
    return object
end
```
Cool and good. Now problem here is, if we want to change other properties such as "Name", or "Parent", we will get an error because of the clamping part. So we will need to make a check for that.
```
local IntConstrainedValue = {}

function IntConstrainedValue.new(value, min, max)    
    local IntValue = Instance.new("IntValue")
    IntValue.Value = (value>max and max) or (value<min and min) or value

    local object = {MinValue = min or 0, MaxValue = max or 10}

    setmetatable(object, {__index = IntValue,
        __newindex = function(_, property, value) 
           if property == "Value" then --keys are just strings (in our case, they could be any value)
                IntValue[property] = (value>max and max) or (value<min and min) or value
           else
                IntValue[property] = value
           end 
        end
    }) 
    return object
end 
```
```
local object = IntConstrainedValue.new(5, 8, 10)
object.Name = "IntConstrainedValueObject"
object.Parent = workspace

object.MaxValue = 9
print(object.MaxValue) --9
object.Value = 10
print(object.Value) --9 because it was clamped
```
Ok, let's deal with methods now. Methods will work just like properties, the custom methods we will define are inside of `object`, and the default ones should be easily accessed with `__index`. We will also be overriding some of the default methods. For example, our `:Clone()` method has to be custom, because if we used the default `:Clone()` only the `IntValue` will be cloned, and obviously the metatable, the wrapped properties and methods aren't going to get copied with it. 

`object:Clone()` would just create a new IntConstrainedValue, with the same properties as the wrapped object, but we would also want the properties of the `IntValue`, to do that, we would need to change the `__index` of the copy `object` to our copied `object`'s `IntValue` (which is the equivalent of `getmetatable(copy_object).__index = getmetatable(copied_object).__index`).

```
local IntConstrainedValue = {}

function IntConstrainedValue.new(value, min, max)    
    local IntValue = Instance.new("IntValue")
    IntValue.Value = (value>max and max) or (value<min and min) or value 

    local object = {MinValue = min or 0, MaxValue = max or 10}

    function object:Clone() 
        local clone = IntConstrainedValue.new(self.Value, self.MinValue, self.MaxValue)
        getmetatable(clone).__index = getmetatable(self).__index
        return clone
    end

    setmetatable(object, {__index = IntValue, 
        __newindex = function(_, property, value) 
           if property == "Value" then 
                IntValue[property] = (value>max and max) or (value<min and min) or value
           else
                IntValue[property] = value
           end        
        end
    }) 
    return object
end
```
```
local object = IntConstrainedValue.new(5, 8, 10)
object.Name = "IntConstrainedValueObject"
object.Parent = workspace

local object2 = object:Clone()
object2.Parent = workspace
print(object.Value, object.MaxValue, object.MinValue) --5, 8, 10 same as the first object
```
Amazing!

We're not keeping the methods in the custom wrapped `IntConstrainedValue` class as we would do in a normal OOP setup, here we're creating them inside of the `object` inside of the constructor itself. Now this is complicated. Because we're already using `object`'s metatable and `__index` for the object, we can't make it inherit from the class (and a table can't have more than a single metatable, and a metatable cannot contain more than a single metamethod of each type). We also can't make it so `IntValue` inherits from the class (basically we have multiple layers of inheritance, `object` inherits from `IntValue` which inherits from `IntConstrainedValue`, if we index `object` with a method, it looks through `IntValue`, then looks through `IntConstrained`) beacuse we cannot edit the metatable of an Instance! It's locked. So it's almost impossible to do so, but I can think of many hacky ways of doing so, but's it's just gonna be confusing and will ruin the taste of this article.

Implementing a `:Destroy()` is gonna be a rabbit hole of garbage collection and memory leaks (just like with the `:Destroy()` method), but we can't really do anything about it because, this is a problem with the roblox implementation as well. `:Destroy()` will just call `:Destroy()` on `self`'s `IntValue`, and set `self` to nil. Wrapping `:Destroy()`!

We will face problems with garbage collection because there are many references to different things. For example, even though we destroy `IntValue`, there is a reference to it inside of the constructor (the `IntValue` variable), and also a reference to it because it's stored inside of the metatable (it's pointed to  by `__index`), which is why we can still access its properties. 

```
function object:Destroy()
    getmetatable(self).__index:Destroy()
    self = nil
end
```
```
local object = IntConstrainedValue.new(5, 8, 10)
object.Name = "IntConstrainedValueObject"
object.Parent = workspace

object:Destroy() 
print(object) --still prints it, although the IntValue parented to workspace is removed
print(object.Value, object.MaxValue) --also prints the various properties
```
There are ways to make it so the `:Destroy()` actually has side-effects that make you unable to use other references to the destroyed object by removing what the objects have (the properties and methods), for example we can `setmetatable(self, {})` to an empty table, that way you can no longer access the methods, and properties of the `IntValue`. For `object`'s properties and method, we simply loop through `object` and set everything to nil. Although the other references are still tables, they just don't redirect to properties and methods, they're empty.

```
function object:Destroy()
    getmetatable(self).__index:Destroy()
    setmetatable(self, {}) --make IntValue's properties and method inaccessible
    for i, v in pairs(self) do
         self[i] = nil
    end
    self = nil
end
```
```
local object = IntConstrainedValue.new(5, 8, 10)
object.Name = "IntConstrainedValueObject"
object.Parent = workspace

object:Destroy() 
print(object) --table: some address
print(object.Value, object.MaxValue) --nil, nil
```

Ok, let's move on with events! Before talking about events in general, let's talk about the idea behind events: if something happens, inform a listener (run all functions connected to that event). Let's talk about how we would do "if something happens" part, we need to check. Let's we wanted to make a `.Changed` (wrapping the `.Changed` event!) that will work with `object` properties, firing if a property changed. What would I do to check? Well a naive solution is to make a while loop that constanly checks for `object`'s properties, and for `IntValue`'s properties we just hook a `.Changed` event that will inform us. But that's terrible. 

Another solution is *setters*, a setter is literaly a method that sets a property to something (for example, `:SetPrimaryPartCFrame`, in our case we would have something like `:SetMaxValue()` or `:SetMinValue()`). Since we're calling  this function to change the properties, we can simply inform the listenner that we changed a property, and we don't have to constanly check, we just inform the listener once the function is called. And for `IntValue`'s properties, we just hook `.Changed` again.

```
local object = {MinValue = min or 0, MaxValue = max or 10}

function object:SetMaxValue(value) 
    object.MaxValue = value
    ... --inform the listener
end

IntValue.Changed:Connect(function() 
    ... --inform the listener
end)
```

But this is not so good, because you can still do `object.MaxValue = property` for example, and that wouldn't fire the event. You can just keep on using the setter, but if you make a public object wrapper, people don't want to be forced to use setters.

Best solution is, to use a [proxy table](https://www.lua.org/pil/13.4.4.html) (it's important that you know this concept, because I won't be dwelling on it a lot). It's essentially a table that tracks whenever you read or write to a table, using `__index` and `__newindex`.

```
local t = {x = 5}
local proxy = setmetatable({}, {__index = function(_, prop) print("User accessed an index") return t[prop] end,
               __newindex = function(_, prop, value) print("User changed or created new index") t[prop] = value end
})


local h = proxy.x
--prints "User accessed an index", it's detecting that we did.
proxy.f = 2 
--prints "User has changed or created a new index", detected
```
The proxy table works almost like the interface that we talked about, it's the one that gets indexed, and once it does, it indexes the table it's connected to, and that way we can know if it was indexed. It's like we added a layer between them, and that layer redirects us to the table, while letting us do more stuff in between. In our case, we will be doing something like this! (Note that our proxy table won't contain a `__index`)
```
local object = {properties}
local proxy = setmetatable({}, {
__newindex = function(_, prop, value) 
                 if object[prop] ~= value then --if value changed from last
                     ... --inform the listener
                 end
                 object[prop] = value
             end),
__index = object
})
```
That's it! Let's do that to our implementation.
```
local IntConstrainedValue = {}

function IntConstrainedValue.new(value, min, max)    
    local IntValue = Instance.new("IntValue")
    IntValue.Value = (value>max and max) or (value<min and min) or value 
    
    local object = {MinValue = min or 0, MaxValue = max or 10}

    local proxy = setmetatable({}, {
        __newindex = function(_, prop, value)
            if object[prop] ~= value then
                ... --inform the listener
            end
            object[prop] = value
        end,
        __index = object
    })

    function object:Clone() 
        local clone = IntConstrainedValue.new(self.Value, self.MinValue, self.MaxValue)
        getmetatable(clone).__index = getmetatable(self).__index
        return clone
    end

    function object:Destroy()
        getmetatable(self).__index:Destroy()
        setmetatable(self, {}) --make IntValue's properties and method inaccessible
        for i, v in pairs(self) do
            self[i] = nil
        end
        self = nil
    end

    setmetatable(object, {__index = IntValue, 
        __newindex = function(_, property, value) 
           if property == "Value" then 
                IntValue[property] = (value>max and max) or (value<min and min) or value
           else
                IntValue[property] = value
           end        
        end
    }) 
    return proxy --return proxy instead
end
```
Everything should still work the same! We return `proxy` instead.

Now! The listener part! How would we be able to listen for whenever that `... --inform the listener` part is gonna fire. Well using bindable events! First of all, I want you to change the way you think about events, in case you haven't yet. Events, are actual values, they're `RBXScriptSIignal`s. Whenever you're indexing an event, you're getting that `RBXScriptSignal`.
```
print(part.Touched) --Signal Touched
print(type(part.Touched)) --userdata
print(typeof(part.Touched)) --RBXScriptSignal
```
As you've seen above, `RBXScriptSignal`s are just userdatas, they have methods and properties. One of the methods, that you are definitely aware of, is `:Connect()`, yeah (also `:Wait()`). This method connects a function to the `RBXScriptSignal`. The `RBXScriptSignal` works just like an alarm, if something happens (if it's alarmed), it runs all functions connected to it. Know, since you know all that, something like this:
```
local touched = part.Touched

touched:Connect(function() A

end)
```
is totally valid.


So, what's special about bindable events? Well, we can fire them whenever we want with `:Fire()`, which will repalce the `... --inform the listener` part, and listen to that with `.Event`. We can have a key inside of an object, that will hold the bindable event's `RBXScriptSignal` (`bindable.Event`), that way we can name our events however we want, where the key is the event's name. This is what I mean:
```
local objects = {}

function objects.new() --some arbitrary OOP setup
    local bindable = Instance.new("BindableEvent") --used for event, we don't really need to parent it, it's a dummy object
    local object = {Changed = bindable.Event} --the RBXScriptSignal
    function object:FireChanged() --just some random function that will fire the event
        bindable:Fire("hi") --inform object.Changed, you can pass parameters just like events
    end
    return object
end

local o = objects.new()

--o.changed points to bindable.Event, which is fired with :Fire()

o.Changed:Connect(function(parameter) --you can get the parameters
     print(parameter) --prints "hi" after calling :FireChanged()
end)

object:FireChanged() --inform
```
I hope you got the idea! Let's implement this to our main script. The `.Changed` event will fire whenever our proxy runs `__newindex`. We will pass `prop`, the changed property, as a parameter.
```
local IntConstrainedValue = {}

function IntConstrainedValue.new(value, min, max)    
    local IntValue = Instance.new("IntValue")
    IntValue.Value = (value>max and max) or (value<min and min) or value 
	    
    local changed = Instance.new("BindableEvent") --the bindable
	
    local object = {MinValue = min or 0, MaxValue = max or 10, Changed = changed.Event} --its rbxscriptsignal
	
    local proxy = setmetatable({}, {
        __newindex = function(_, prop, value)
            if object[prop] ~= value then
                changed:Fire(prop) --we fire with whatever property 
            end
            object[prop] = value
		end,
		__index = object
    })
	
	IntValue.Changed:Connect(function() 
		changed:Fire("Value") --we fire with "Value"
	end)
	
	function object:Clone() 
        local clone = IntConstrainedValue.new(self.Value, self.MinValue, self.MaxValue)
        getmetatable(clone).__index = getmetatable(self).__index
        return clone
    end

    function object:Destroy()
        getmetatable(self).__index:Destroy()
        setmetatable(self, {}) 
        for i, v in pairs(self) do
            self[i] = nil
        end
        self = nil
    end

    setmetatable(object, {__index = IntValue, 
        __newindex = function(_, property, value) 
           if property == "Value" then 
                IntValue[property] = (value>max and max) or (value<min and min) or value
           else
                IntValue[property] = value
           end        
        end
    }) 
    return proxy --return proxy instead
end
```
```
local object = IntConstrainedValue.new(5, 8, 10)
object.Name = "IntConstrainedValueObject"
object.Parent = workspace

object.Changed:Connect(function(prop)
	print(prop, "=", object[prop])
end)

object.Value = 9
object.MinValue = 4
```
And the output would print what you'd expect it to print! Now one thing, the `Changed` event works differently for Value Objects. It will only fire with `.Value` property changes, and doesn't pass that as a property, it just passes the changed value. So we just `changed:Fire("Value")`. This is cool! We might also make a `.MaxClamped` and `.MinClamped` event, that fire whenever `.Value` either is more than `.MaxValue` or less than `.MinValue` and it's clamped. Try implementing those yourself!
And by the way, we can actually use `:Disconnect()` with this! Because `:Connect()` is returning it, thus we can disconnect the `changed.Event`.

And that's it! As usual, have a wonderful day!
