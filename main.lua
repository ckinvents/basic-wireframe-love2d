----
-- 3D Engine Expirement
-- Connor Ennis
-- 3/17/2018
----

function love.load(arg)
  if arg and arg[#arg] == "-debug" then
    require("mobdebug").start()
    isdebug = true
  end
  WIDTH = love.graphics.getWidth()
  HEIGHT = love.graphics.getHeight()
  SCALECONST = 800
  CENTERCAM = {WIDTH, HEIGHT}
  PI = math.pi
  IDENT2D = {
    {1, 0, 0},
    {0, 1, 0},
    {0, 0, 1}
  }
  IDENT3D = {
    {1, 0, 0, 0},
    {0, 1, 0, 0},
    {0, 0, 1, 0}
  }
  starfield = {}
  ent = {}
  score = 0
  state = "load"
  models = {
    ["shipModel"] = {
      {50, 0, 0, -50, -40, 0, -30, 0, 30},
      {-30, 0, 30, -50, 40, 0, 50, 0, 0},
      {50, 0, 0, -50, -40, 0, -30, 0, -30},
      {-30, 0, -30, -50, 40, 0, 50, 0, 0},
      {-30, 0, -30, -30, 0, 30, -50, -40, 0},
      {-30, 0, -30, -30, 0, 30, -50, 40, 0}
    },
    ["octohedron"] = {
      {
        {40, 0, 0, 1},
        {0, 40, 0, 1},
        {0, 0, 40, 1}
      },
      {
        {-40, 0, 0, 1},
        {0, 40, 0, 1},
        {0, 0, 40, 1}
      },
      {
        {40, 0, 0, 1},
        {0, -40, 0, 1},
        {0, 0, 40, 1}
      },
      {
        {-40, 0, 0, 1},
        {0, -40, 0, 1},
        {0, 0, 40, 1}
      },
      {
        {40, 0, 0, 1},
        {0, 40, 0, 1},
        {0, 0, -40, 1}
      },
      {
        {-40, 0, 0, 1},
        {0, 40, 0, 1},
        {0, 0, 40, 1}
      },
      {
        {40, 0, 0, 1},
        {0, -40, 0, 1},
        {0, 0, -40, 1}
      },
      {
        {-40, 0, 0, 1},
        {0, -40, 0, 1},
        {0, 0, -40, 1}
      }
    },
    ["stem"] = toTriangles(loadModel("cube.raw", 0.1))
  }
  --ship = newPlayer(WIDTH/2, HEIGHT/2, 0, 0, 0, 0, 10, 0, "shipModel")
  thing = newPlayer(0, 0, -1, 0, 0, 0, 255, 255, 255, "stem")
  --thing1 = newPlayer(200, 300, 0, PI/3, 0, 0, 10, 0, "stem")
  --thing2 = newPlayer(600, 200, 0, PI/3, 0, 0, 10, 0, "stem")
  --thing3 = newPlayer(400, 500, 0, PI/3, 0, 0, 10, 0, "stem")
  --thing4 = newPlayer(400, 500, 0, PI/3, 0, 0, 10, 0, "stem")
  starfield = {}
  axis = {0, 0, 0, 0, 0, 0, 0, 0, 0}
end

function love.update(dt)
  if love.keyboard.isDown("escape") then
    love.event.quit()
  end
  updatePlayer(thing, dt)
  --ship.xA = ship.xA + dt
  --ship.yA = ship.yA + dt
  --ship.zA = ship.zA + dt
  --thing.xA = thing.xA - dt
  thing.yA = thing.yA - dt
  --thing.zA = thing.zA - dt
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("FPS: "..love.timer.getFPS(), 0, 0)
  --drawPlayer(ship)
  drawPlayer(thing)
  --drawPlayer(thing1)
  --drawPlayer(thing2)
  --drawPlayer(thing3)
  --drawPlayer(thing4)
end

function loadModel(dir, scale)
  local newModel = {}
  local triangle = {}
  local point = {}
  local num = ""
  local file = love.filesystem.newFile(dir)
  file:open("r")
  local data = file:read()
  file:close()
  print(data)
  local charCount = 1
  while charCount <= #data do
    triangle = {}
    for p = 1, 3 do
      point = {}
      for c = 1, 3 do
        num = ""
        while charCount <= #data and string.sub(data, charCount, charCount) ~= " " and string.sub(data, charCount, charCount) ~= "\\" do
          num = num..string.sub(data, charCount, charCount)
          charCount = charCount + 1
        end
        if string.sub(data, charCount, charCount) == "\\" then
          charCount = charCount + 4
        end
        charCount = charCount + 1
        point[c] = tonumber(num) * scale
      end
      point[4] = 1 
      triangle[p] = point
    end
    table.insert(newModel, triangle)
  end
  return newModel
end

function copyVector(vector)
  local newVector = {}
  for i = 1, #vector do
    newVector[i] = vector[i]
  end
  return newVector
end

function copyMatrix(matrix)
  local newMatrix = {}
  for i = 1, #matrix do
    newMatrix[i] = copyVector(matrix[i])
  end
  return newMatrix
end

--2D transformation functions
function toVertices(matrix)
  local vertices = {}
  for i = 1, #matrix do
    for j = 1, 2 do
      table.insert(vertices, matrix[i][j])
    end
  end
  return vertices
end

function multiplyMatrix(vector, matrix)
  return {
    (matrix[1][1]*vector[1] + matrix[1][2]*vector[2] + matrix[1][3]*vector[3]),
    (matrix[2][1]*vector[1] + matrix[2][2]*vector[2] + matrix[2][3]*vector[3]),
    (matrix[3][1]*vector[1] + matrix[3][2]*vector[2] + matrix[3][3]*vector[3]),
    (matrix[1][1]*vector[4] + matrix[1][2]*vector[5] + matrix[1][3]*vector[6]),
    (matrix[2][1]*vector[4] + matrix[2][2]*vector[5] + matrix[2][3]*vector[6]),
    (matrix[3][1]*vector[4] + matrix[3][2]*vector[5] + matrix[3][3]*vector[6]),
    (matrix[1][1]*vector[7] + matrix[1][2]*vector[8] + matrix[1][3]*vector[9]),
    (matrix[2][1]*vector[7] + matrix[2][2]*vector[8] + matrix[2][3]*vector[9]),
    (matrix[3][1]*vector[7] + matrix[3][2]*vector[8] + matrix[3][3]*vector[9])
  }
end

function translateVector(vector, x, y)
  local transMatrix = {
    {1, 0, x},
    {0, 1, y},
    {0, 0, 1}
  }
  return multiplyMatrix(vector, transMatrix)
end
  
function rotateVector(vector, angle) --Wikipedia'd
  local rotMatrix = {
    {math.cos(angle), -math.sin(angle), 0},
    {math.sin(angle), math.cos(angle), 0},
    {0, 0, 1}
  }
  return multiplyMatrix(vector, rotMatrix)
end

--3D transformation functions
function toTriangles(matrix)
  local triangles = {}
  local triangle = {}
  for t = 1, #matrix do
    triangle = {}
    for p = 1, 3 do
      for c = 1, 3 do
        table.insert(triangle, matrix[t][p][c])
      end
    end
    table.insert(triangles, triangle)
  end
  return triangles
end
      
function multiplyMatrix3D(vector, matrix)
  return {
    (matrix[1][1]*vector[1] + matrix[1][2]*vector[2] + matrix[1][3]*vector[3] + matrix[1][4]),
    (matrix[2][1]*vector[1] + matrix[2][2]*vector[2] + matrix[2][3]*vector[3] + matrix[2][4]),
    (matrix[3][1]*vector[1] + matrix[3][2]*vector[2] + matrix[3][3]*vector[3] + matrix[3][4]),
    (matrix[1][1]*vector[4] + matrix[1][2]*vector[5] + matrix[1][3]*vector[6] + matrix[1][4]),
    (matrix[2][1]*vector[4] + matrix[2][2]*vector[5] + matrix[2][3]*vector[6] + matrix[2][4]),
    (matrix[3][1]*vector[4] + matrix[3][2]*vector[5] + matrix[3][3]*vector[6] + matrix[3][4]),
    (matrix[1][1]*vector[7] + matrix[1][2]*vector[8] + matrix[1][3]*vector[9] + matrix[1][4]),
    (matrix[2][1]*vector[7] + matrix[2][2]*vector[8] + matrix[2][3]*vector[9] + matrix[2][4]),
    (matrix[3][1]*vector[7] + matrix[3][2]*vector[8] + matrix[3][3]*vector[9] + matrix[3][4])
  }
end

function translateVector3D(vector, x, y, z)
  local transMatrix = {
    {1, 0, 0, x},
    {0, 1, 0, y},
    {0, 0, 1, z}
  }
  return multiplyMatrix3D(vector, transMatrix)
end  

function rotateVector3D(vector, xA, yA, zA) --Had to wikipedia this, too. Didn't want to find it by hand
  local transMatrixX = {}
  local transMatrixY = {}
  local transMatrixZ = {}
  if xA ~= 0 then
    transMatrixX = {
      {1, 0, 0, 0},
      {0, math.cos(xA), -math.sin(xA), 0},
      {0, math.sin(xA), math.cos(xA), 0}
    }
  else
    transMatrixX = IDENT3D
  end
  if yA ~= 0 then
    transMatrixY = {
      {math.cos(yA), 0, math.sin(yA), 0},
      {0, 1, 0, 0},
      {-math.sin(yA), 0, math.cos(yA), 0}
    }
  else
    transMatrixY = IDENT3D
  end
  if zA ~= 0 then
    transMatrixZ = {
      {math.cos(zA), -math.sin(zA), 0, 0},
      {math.sin(zA), math.cos(zA), 0, 0},
      {0, 0, 1, 0}
    }
  else
    transMatrixZ = IDENT3D
  end
  return multiplyMatrix3D(multiplyMatrix3D(multiplyMatrix3D(vector, transMatrixX), transMatrixY), transMatrixZ)
end

function locRotateVector3D(vector, a, vX, vY, vZ)
  local transMatrix = {}
  local cos = math.cos(a)
  local sin = math.sin(a)
  transMatrix = {
    {vX * vX * (1 - cos) + cos, vX * vY * (1 - cos) - vZ * sin, vX * vZ * (1 - cos) + vY * sin, 0},
    {vY * vX * (1 - cos) + vZ + sin, vY * vY * (1 - cos) + cos, vY * vZ * (1 - cos) - vX * sin, 0},
    {vZ * vX * (1 - cos) - vY * sin, vZ * vY * (1 - cos) + vX * sin, vZ * vZ * (1 - cos) + cos, 0}
  }
  return multiplyMatrix3D(vector, transMatrix)
end
  

function perspectTrans(vector)
  return {
    vector[1] / vector[3],
    vector[2] / vector[3],
    vector[3],
    vector[4] / vector[6],
    vector[5] / vector[6],
    vector[6],
    vector[7] / vector[9],
    vector[8] / vector[9],
    vector[9]
  }
end

function newPlayer(x, y, z, xA, yA, zA, red, green, blue, model)
  local player = {}
  player.model = models[model]
  player.x = x
  player.xV = 0
  player.y = y
  player.yV = 0
  player.z = z
  player.zV = 0
  player.locXVec = {1, 0, 0, 0, 0, 0, 0, 0, 0}
  player.locYVec = {0, 1, 0, 0, 0, 0, 0, 0, 0}
  player.locZVec = {0, 0, 1, 0, 0, 0, 0, 0, 0}
  player.locXA = 0
  player.locYA = 0
  player.locZA = 0
  player.xA = xA
  player.xAV = 0
  player.yA = yA
  player.yAV = 0
  player.zA = zA
  player.zAV = 0
  player.lives = lives
  player.state = "alive"
  player.type = "player"
  player.color = {red, green, blue}
  return player
end

function updatePlayer(player, dt)
  player.xV = player.xV * dt
  player.yV = player.yV * dt
  player.zV = player.zV * dt
  if love.keyboard.isDown("down") then
    player.zV = player.zV + dt
  elseif love.keyboard.isDown("up") then
    player.zV = player.zV - dt
  end
  if love.keyboard.isDown("right") then
    player.xV = player.xV - dt
  elseif love.keyboard.isDown("left") then
    player.xV = player.xV + dt
  end
  if love.keyboard.isDown("lshift") then
    player.yV = player.yV - dt
  elseif love.keyboard.isDown("space") then
    player.yV = player.yV + dt
  end
  player.x = player.x + player.xV
  player.y = player.y + player.yV
  player.z = player.z + player.zV
end

function drawPlayer(player, fill)
  local oldColor = {}
  oldColor[1], oldColor[2], oldColor[3] = love.graphics.getColor()
  local drawMatrix = {}
  -- Compute local rotations.
  for t = 1, #player.model do
    --World transformations.
    drawMatrix[t] = perspectTrans(translateVector3D(rotateVector3D(player.model[t], player.xA, player.yA, player.zA), player.x, player.y, player.z))
    --Scale to world.
    drawMatrix[t][1] = drawMatrix[t][1] * HEIGHT/2 + WIDTH/2
    drawMatrix[t][4] = drawMatrix[t][4] * HEIGHT/2 + WIDTH/2
    drawMatrix[t][7] = drawMatrix[t][7] * HEIGHT/2 + WIDTH/2
    drawMatrix[t][2] = drawMatrix[t][2] * HEIGHT/2 + HEIGHT/2
    drawMatrix[t][5] = drawMatrix[t][5] * HEIGHT/2 + HEIGHT/2
    drawMatrix[t][8] = drawMatrix[t][8] * HEIGHT/2 + HEIGHT/2
  end
  for t = 1, #drawMatrix do
    love.graphics.setColor(player.color[1], player.color[2], player.color[3])
    if fill then
      love.graphics.polygon("fill", drawMatrix[t][1], drawMatrix[t][2], drawMatrix[t][4], drawMatrix[t][5], drawMatrix[t][7], drawMatrix[t][8], drawMatrix[t][1], drawMatrix[t][2])
    else
      love.graphics.line(drawMatrix[t][1], drawMatrix[t][2], drawMatrix[t][4], drawMatrix[t][5])
      love.graphics.line(drawMatrix[t][4], drawMatrix[t][5], drawMatrix[t][7], drawMatrix[t][8])
      love.graphics.line(drawMatrix[t][7], drawMatrix[t][8], drawMatrix[t][1], drawMatrix[t][2])
    end
    --love.graphics.setColor(0, 255, 0)
    --for p = 1, 3 do
      --love.graphics.circle("fill", drawMatrix[t][2*p-1], drawMatrix[t][2*p], 5)
      --love.graphics.print(drawMatrix[t][2*p-1].." "..drawMatrix[t][2*p].."\n", 0, t*40-40 + p*10)
    --end
  end
  love.graphics.setColor(oldColor[1], oldColor[2], oldColor[3])
end
