local function xpairs(t)
  local function iterator(invariant, control) 
    control = control + 1
    if control <= #invariant then 
        return control, invariant[control]
    end
  end
  return iterator, t, 0 
end
