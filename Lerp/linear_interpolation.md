*Linear Interpolation* might sound to you like a fancy word. Don't worry, it is rather simple. Also, I'm sure you heard of the `:Lerp()` function, which lerps cframes, or in another way, makes a part move smoothly from Point A to Point B. Now what's exciting is, Lerp is actually short for **L**inear Int**erp**olation. So that's what this topic is about. 
To "lerp" you are always going to use 3 values, or 3 things or whatever..
First, being the starting value, the second is our goal or our value that we wanna hit, and finally, the "alpha". Don't complicate stuff, just think of this "alpha" value as a percentage. So, to repeat, we got a start, a goal, and a percentage (and this percentage can be replace with time sometimes).

Now, let's just demonstrate this, with a graph, we're doing this in a 2D space to make it easier. We can say that we *lerped* our value from 1 to 3.

![0_1560112780012_diagram-20190609.png](https://i.ibb.co/DpSFXfk/1560112633822-diagram-20190609.png) 

Now you can see her, our Y axis has our value and X axis having our percentage, you can notice at the Value axis we have 1 as the start value, and 3 as the goal.
And our Percentage axis goes from 0 to 1, since that's how percentage works (you multiply that numeber with 100 to get a percentage so yeah , 0.5 * 100 = 50%          1 * 100 = 100). Now what i'm about to say, is gonna make all of these little simple ideas tick in your brain. You can see that *2* corresponds with *0.5*. And that's since 2 is techniclly our half way through from 1 to hitting 3, it's the middle of 1 and 3. And 0.5 being 50%. Get it? I hope you do. That's why we have percentage there. 3 Corresponds with 1 (100%) because it 3 is our goal, we hit 100% of the lerp, and 1 corresponds with 0 since we didnt lerp anything yet.



 So we can come up with a super simple equation. ( α  this is the "alpha" symbol)
**Start + (Goal - Start) *  α**
We simply subtract the start from the goal to get the differnce between them, or the "distance" you may call it that we are going to lerp, multip
ly it by alpha, the percentage, and add that to the start, so we can add to our starting position the distance.
So for an example, let's say we wanna lerp our value from 10 to 25, and we wanna go 0.6 the way. 10 + (25-10) * 0.6 = 19, and that's right.


Now, done with the math part, let's go to the scripting part, using `:Lerp()`.
In roblox, this function is used to just lerp CFrame values, you can't lerp other values like integers sadly, but you can do that, i'll show you later.
So, the first argument is, the goal cframe, just like we saw in our math bit, and the start cframe is the part's cframe that we used this function on. The second argument, an alpha number or just a percentage, and by a percentage we mean a number between 0 and 1. You can see that we set the part's cframe to the lerped version of its cframe.

```
lcoal part1 = workspace.Part1
local part2 = workspcae.Part2

part1.CFrame = part1.CFrame:Lerp(Part2.CFrame, 0.2)
```

Now, I put the percentage as 0.2, which means 20% and it should go fifth of the lerp.



![enter image description here](https://gyazo.com/d20e766c81e17fefd06dc55a774f369e.gif)

See? Just like we said. let's try with 0.5

![enter image description here](https://gyazo.com/3797e838de6be514bc606c49fdcd1459.gif)

It goes half the way. Now, how would I make this smoothly go from start to finish? 
Welp, we gotta put it inside of a for loop, why a for loop?
```
for i = 0, 1, 0.01 do
     wait(0.1)
     part1.CFrame = part1.CFrame:Lerp(Part2.CFrame, i)
end
```
![](https://gyazo.com/c3460e8d2da13deb40445ccf0344ee84.gif)

We put it inside of a for loop, and set the percentage argument to *i*, because, think about it, the first time it loops, i will be 0.1, it will lerp 0.1 the way, second time it loops i would be 0.2, it will lerp 0.2 the way, and so on until *i* is 1, and we go 100% the lerp to hit our goal.

And you know, we can only lerp cframes (and also vector3 and color3) using the built-in function :Lerp().
Let's make our own function that can lerp number values.
We would need our 3 values that we worked with.
```
function lerp(start, goal, alpha)
    --we can use our super simple equation at the start, using the 3 values
    return start + (goal - start) * alpha
end

print(lerp(0, 10, 0.5)) --this would interpolate our value to 5, since 0.5 is half the way

for i = 0, 1, 0.1 do
      print(lerp(0, 10, i))
end
```
And that's really it, now just wanted to point out that Linear Interpolation does have another use, and it's finding unkown data using those graphs. Not gonna cover that since it doesn't really have relation to programming. But check them out yourself.
And remember to "never stop lerning".
