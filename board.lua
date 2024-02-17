--Определение класса "Игровое поле"
local Board = {}
Board.__index = Board

--Конструктор для создания нового игрового поля
function Board.Init(width, height)
  local self = setmetatable({}, Board)
  self.width = width
  self.height = height
  self.grid = {}

  --Инициализация игрового поля
  for y = 1, height do
    self.grid[y] = {}
      for x = 1, width do
        self.grid[y][x] = string.char(math.random(65, 71))
        while(self:CheckMatchAtInit(y, x)) do --Проверка на готовые комбинации при инициализации
          --Если возвращается true, то в этом месте будет образована комбинация из 3х, реролим значение пока не получим уникальное.
          self.grid[y][x] = string.char(math.random(65, 70))
        end
      end
  end

  return self
  
end

--Метод для отображения игрового поля в консоли
function Board:Dump()
  --Вывод сетки координат по X
  io.write("   ")
  for x = 1, self.width do
    io.write(x .. " ")
  end
  print() --Переход на новую строку

  --Вывод игрового поля с кристаллами
  for y = 1, self.height do
    if (y < self.height) then
      io.write(y .. " |") --Вывод координаты строки 1-9
    else
      io.write(y .. "|") --Вывод координаты строки 10
    end
    for x = 1, self.width do
      io.write(self.grid[y][x] .. " ") --Вывод кристалла и пробела
    end
    print() --Переход на новую строку для следующей строки
  end
  print() --Отступ для разделения полей между ходами
end

--Метод для выполнения действий на поле
function Board:Tick()
  
  --Проверка на наличие комбинаций..
  --Пока true будем выполнять смещение
  while(self:CheckMatchesOnField()) do
    --Дебаг, здесь смотрим где и что образуется и как смещается
    print("Debug. Step into: ")
    self:Dump()
    --Смещаем кристаллы вниз
    self:ShiftDown()
  end
  
  --Проверка на наличие ходов на поле
  --Перемешиваем поле пока не найдём возможность походить
  local reRollCount = 0
  while(self:MovesAvailable() == false) do
    print("No moves available, rerolling the field")
    self:Mix(self.grid)
    reRollCount = reRollCount + 1
  end
  
  --Дебаг
  if(reRollCount > 0) then
    print("Rerolled "..reRollCount.." times")
  end

end

--Метод для проверки на комбинацию при инизиализации поля
--Проверяем уже отрисованные кристаллы слева и сверху
function Board:CheckMatchAtInit(y, x)
  if(x > 2) then
    if(self.grid[y][x] == self.grid[y][x-1] and self.grid[y][x] == self.grid[y][x-2]) then --Если 2 кристалла сзади совпадают с текущим будем его реролить
      return true
    end
    return false
  elseif(y > 2) then
    if(self.grid[y][x] == self.grid[y-1][x] and self.grid[y][x] == self.grid[y-2][x]) then --Если 2 кристалла сверху совпадают с текущим будем его реролить
      return true
    end
    return false
  end
end

--Метод для проверки образования ряда или колонки из трех и более кристаллов
function Board:CheckMatchesOnField()
  
  local result = false
  
  --Основной цикл проходит всё поле
  for y = 1, self.height do
    for x = 1, self.width do
      local currentValue = self.grid[y][x]
      
      --Ищем совпадение 3+ по горизонтали от каждой позиции на поле
      local countHorizontal = 1
      for i = x + 1, self.width do
        if(self.grid[y][i] == currentValue) then
          countHorizontal = countHorizontal + 1
        else
          break
        end
      end
      
      --Если нашли комбинацию из 3+ кристаллов помечаем их на удаление 'x' и последующее смещение вниз
      if(countHorizontal >= 3) then
        for i = x, x + countHorizontal -1 do
          self.grid[y][i] = 'x'
        end
        --Поместить поверап в начало собраной комбинации если count больше 3х
        --[[if(countHorizontal > 3) then
          self.grid[y][x] = 'Z' 
        end]]--
        result = true
      end
      
      --Ищем совпадение 3+ по вертикали от каждой позиции на поле
      local countVertical = 1
      for i = y + 1, self.height do
        if(self.grid[i][x] == currentValue) then
          countVertical = countVertical + 1
        else
          break
        end
      end
      
      --Если нашли комбинацию из 3+ кристаллов помечаем их на удаление 'x' и последующее смещение вниз
      if(countVertical >= 3) then
        for i = y, y + countVertical -1 do
          self.grid[i][x] = 'x'
        end
        --Поместить поверап в начало собраной комбинации если count больше 3х
        --[[if(countVertical > 3) then
          self.grid[y][x] = 'Z' --Поместить поверап в начало собраной комбинации
        end]]--
        result = true
      end
      
    end
  end
  return result

end

--Метод смещения кристаллов вниз
function Board:ShiftDown()
  
  local continue = false
  
  --Цикл проходит всё поле пока на нём не останется элементов помеченых на удаление и требущих смещение
  --Как только находим кристалл из комбинации помеченый на удаление, на его место ставим кристалл сверху, а верхний помечаем на удаление
  --На верхней строке вместо смещения генерируем новые кристаллы и даём команду циклу repeat остановится
  repeat
    for y = 1, self.height do
      for x = 1, self.width do
        if(self.grid[y][x] == 'x' and y > 1) then
          self.grid[y][x] = self.grid[y-1][x]
          self.grid[y-1][x] = 'x'
          continue = true
        elseif(self.grid[y][x] == 'x' and y == 1) then
          self.grid[y][x] = string.char(math.random(65, 70))
          continue = false
        end
      end
    end
  until (continue == false)
  
end

--Проверка поля на наличие ходов
function Board:MovesAvailable()
  
  result = false
  
  --Цикл проходит всё поле и на каждой позиции определяет, что если ЧЕРЕЗ 1 кристалл в любом направлении есть 2 аналогичных, то это возможность походить
  --Как только находим возможность походить будем прерывать цикл, так как дальше его гонять нет смысла
  for y = 1, self.height do
    for x = 1, self.width do
      if(x > 3 and self.grid[y][x] == self.grid[y][x-2] and self.grid[y][x] == self.grid[y][x-3]) then --Проверка возмоности походить влево от текущей позиции
        result = true
        break --Прерываем внутренний цикл
      end
      if(x < self.width -3 and self.grid[y][x] == self.grid[y][x+2] and self.grid[y][x] == self.grid[y][x+3]) then --Проверка возмоности походить влево от текущей позиции
        result = true
        break --Прерываем внутренний цикл
      end
      if(y > 3 and self.grid[y][x] == self.grid[y-2][x] and self.grid[y][x] == self.grid[y-3][x]) then --Проверка возмоности походить влево от текущей позиции
        result = true
        break --Прерываем внутренний цикл
      end
      if(y < self.height -3 and self.grid[y][x] == self.grid[y+2][x] and self.grid[y][x] == self.grid[y+3][x]) then --Проверка возмоности походить влево от текущей позиции
        result = true
        break --Прерываем внутренний цикл
      end
    end
    if(result) then
      break --Прерываем внешний цикл
    end
  end
  
  return result

end

--Метод для перемешивания кристаллов
function Board:Mix(grid)
  local height = self.height
  local width = self.width
  
  --Перемешиваем строки
  for i = 1, height do
    local j = math.random(height)
    grid[i], grid[j] = grid[j], grid[i]
  end
  
  --Далее перемешиваем значение в строках
  for i = 1, height do
    for j = 1, width do
      local k = math.random(width)
      grid[i][j], grid[i][k] = grid[i][k], grid[i][j]
    end
  end
  
end

--Метод для хода игрока
function Board:PlayerMove(y, x, direction)

  --Проверяем, что координаты находятся в пределах поля
  if (x < 1 or x > self.width or y < 1 or y > self.height) then
    print("Coords out of range")
    return false
  end
  
  --Двигаем кристалл в нужном направлении
  self:MoveCrystal(y, x, direction)
  
  --Если после хода кристалл на новой позиции не образует комбинацию, выполняем ход повторно тем самым вернув оба кристалла в изначальные позиции
  if(self:CheckMatchesOnField() == false) then
    print("No combo, move canceled")
    self:MoveCrystal(y, x, direction)
  end
  
  
end

--Метод для смещения кристалла
function Board:MoveCrystal(y, x, direction)

--Двигаем кристалл
  if(direction == "l" and x > 1) then
    print("Move crystal "..self.grid[y][x].. " from "..y.."-"..x.." to "..y.. "-"..(x-1).." except "..self.grid[y][x-1])
    self.grid[y][x-1], self.grid[y][x] = self.grid[y][x], self.grid[y][x-1]
  elseif(direction == "r" and x < self.width) then
    print("Move crystal "..self.grid[y][x].. " from "..y.."-"..x.." to "..y.. "-"..(x+1).." except "..self.grid[y][x+1])
    self.grid[y][x+1], self.grid[y][x] = self.grid[y][x], self.grid[y][x+1]
  elseif(direction == "u" and y > 1) then
    print("Move crystal "..self.grid[y][x].. " from "..y.."-"..x.." to "..(y-1).. "-"..x.." except "..self.grid[y-1][x])
    self.grid[y-1][x], self.grid[y][x] = self.grid[y][x], self.grid[y-1][x]
  elseif(direction == "d" and y < self.height) then
    print("Move crystal "..self.grid[y][x].. " from "..y.."-"..x.." to "..(y+1).. "-"..x.." except "..self.grid[y+1][x])
    self.grid[y+1][x], self.grid[y][x] = self.grid[y][x], self.grid[y+1][x]
  else 
    print("Move is not allowed")
  end
  
end

return Board