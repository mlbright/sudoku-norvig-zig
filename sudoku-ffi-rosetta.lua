#!/usr/bin/env luajit

-- From Rosetta Code: https://rosettacode.org/wiki/Sudoku#with_FFI,_fast

FFI = require("ffi")

local printf = function(fmt, ...)
  io.write(string.format(fmt, ...))
end

local band, bor, lshift, rshift = bit.band, bit.bor, bit.lshift, bit.rshift

local function show(x)
  for i = 0, 8 do
    if i % 3 == 0 then
      print()
    end
    for j = 0, 8 do
      printf(j % 3 ~= 0 and "%2d" or "%3d", x[j + 9 * i])
    end
    print()
  end
end

local function trycell(x, pos)
  local row = math.floor(pos / 9)
  local col = pos % 9
  local used = 0

  if pos == 81 then
    return true
  end

  if x[pos] ~= 0 then
    return trycell(x, pos + 1)
  end

  for i = 0, 8 do
    used = bor(used, lshift(1, x[i * 9 + col] - 1))
  end

  for j = 0, 8 do
    used = bor(used, lshift(1, x[row * 9 + j] - 1))
  end

  row = math.floor(row / 3) * 3
  col = math.floor(col / 3) * 3

  for i = row, row + 2 do
    for j = col, col + 2 do
      used = bor(used, lshift(1, x[i * 9 + j] - 1))
    end
  end

  x[pos] = 1

  while x[pos] <= 9 do
    if band(used, 1) == 0 and trycell(x, pos + 1) then
      return true
    end
    used = rshift(used, 1)
    x[pos] = x[pos] + 1
  end

  x[pos] = 0

  return false
end

local function solve(str)
  local x = FFI.new("char[?]", 81)
  str = str:gsub("[%c%s]", "")

  for i = 0, 81 do
    x[i] = tonumber(str:sub(i + 1, i + 1)) or 0
  end

  if trycell(x, 0) then
    show(x)
  else
    print("no solution")
  end
end

do -- MAIN
  -- solve([[
  --   .....6....59.....82....8....45........3........6..3.54...325..6..................
  -- 	]])
  solve([[
    1 0 0 0 0 7 0 9 0
    0 3 0 0 2 0 0 0 8
    0 0 9 6 0 0 5 0 0
    0 0 5 3 0 0 9 0 0
    0 1 0 0 8 0 0 0 2
    6 0 0 0 0 4 0 0 0
    3 0 0 0 0 0 0 1 0
    0 4 1 0 0 0 0 0 7
    0 0 7 0 0 0 3 0 0
  ]])
end
