check = ({desire, before, after, increment, value})->
  b = Math.abs(desire - before)
  a = Math.abs(desire - after)
  if b < a
    {increment : increment / -2, value: value}
  else
    {increment : increment * 2, value: value+increment}

method = (x, y)=>
  x*y*y*y*x-x-y-x-y*y*y

desire = 1

xi = 31
yi = 31
x = 1
y = 1

for i in [0..200]

  {increment, value} = check
    desire: desire
    before: method(x, y)
    after: method(x+xi, y)
    increment: xi
    value: x
  x = value 
  xi = increment

  {increment, value} = check
    desire: desire
    before: method(x, y)
    after: method(x, y+yi)
    increment: yi
    value: y
  y = value 
  yi = increment

console.log x,y, method(x, y).toFixed(4)*1 , desire




equation = "origin.x + origin.y + ccc + ddd"

generateIndex = (equation)->
  variables = equation.split(/[+ -*/)()]+/)
  index = {}
  chars = ['a'.charCodeAt()..'z'.charCodeAt()].concat ['A'.charCodeAt()..'Z'.charCodeAt()]
  for variable in variables
    if not index[variable]?
      char = String.fromCharCode(chars.shift())
      index[variable] = char
  index

unindexEquation = (equation, index)->
  equation = equation.split("")
  reverse = {}
  for v, k of index
    reverse[k] = v
  for c, i in equation
    if reverse[c]?
      equation[i] = reverse[c]
  equation.join("")

indexEquation = (equation, index)->
  for k, v of index
    equation = equation.split(k).join(v)
  equation

#console.log index = generateIndex(equation)
#console.log ie = indexEquation(equation, index)
#console.log ie = unindexEquation(ie, index)