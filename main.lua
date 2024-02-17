--Импорт класса игрового поля
local Board = require("board")

--Создание игрового поля
local board = Board.Init(10, 10)

--Основной игровой цикл
while true do
  --Вывод игрового поля
  board:Tick()
  board:Dump()

  --Приглашение к вводу
  io.write("> ")
  local input = io.read()

  --Проверка на выход из игры
  if input == "q" then
    break
  end

  --Разбор команды пользователя и выполнение хода
  local command, x, y, direction = input:match("(%a)%s(%d+)%s(%d+)%s(%a)")
  if(command and x and y and direction) then
    x = tonumber(x)
    y = tonumber(y)
    if(command == "m") then
      if(direction == "l" or direction == "r" or direction == "u" or direction == "d") then
        board:PlayerMove(x, y, direction)
      else
        print("Wrong direction. Use l, r, u, d")
      end
    else
      print("Wrong command. Use m y x d for move or q for quit")
    end
  else
    print("Wrong command. Example: m 1 4 l")
  end
  
end