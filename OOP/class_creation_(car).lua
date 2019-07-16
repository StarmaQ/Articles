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
