defmodule Chess do
  use ParamPipe

  ##############
  # INITIATION #
  ##############

  # init an demo array
  def i0() do
    Enum.reduce(0..9, :array.new(10), fn x, acc -> 
      :array.set(x, :array.new(9), acc) 
    end)
  end

  # init chess board
  def i1() do
    Enum.reduce(0..9, :array.new(10), fn x, acc -> 
      cond do
        x == 0 || x == 9 ->
          p = if x > 5, do: 1, else: 0
          Enum.reduce(0..8, :array.new(9), fn x, acc -> 
            :array.set(x, {5 - abs(x-4), p}, acc)
          end)
        x == 2 || x == 7 ->
          p = if x > 5, do: 1, else: 0
          Enum.reduce(0..8, :array.new(9), fn x, acc -> 
            cond do
              x == 1 || x == 7 -> :array.set(x, {6, p}, acc)
              true -> :array.set(x, {-1, -1}, acc)
            end
          end)
        x == 3 || x == 6 ->
          p = if x > 5, do: 1, else: 0
          Enum.reduce(0..8, :array.new(9), fn x, acc -> 
            cond do
              rem(x, 2) == 0 -> :array.set(x, {7, p}, acc)
              true -> :array.set(x, {-1, -1}, acc)
            end
          end)
        true ->
          Enum.reduce(0..8, :array.new(9), fn x, acc -> 
            :array.set(x, {-1, -1}, acc)
          end)
      end
      |1> :array.set(x, acc) 
    end)
  end

  # init two lists and log
  def i2() do
    %{
      l0: [
            {1, {0, 0}},
            {1, {0, 8}},
            {2, {0, 1}},
            {2, {0, 7}},
            {3, {0, 2}},
            {3, {0, 6}},
            {4, {0, 3}},
            {4, {0, 5}},
            {5, {0, 4}},
            {6, {2, 1}},
            {6, {2, 7}},
            {7, {3, 0}},
            {7, {3, 2}},
            {7, {3, 4}},
            {7, {3, 6}},
            {7, {3, 8}},
          ],
      l1: [
            {1, {9, 0}},
            {1, {9, 8}},
            {2, {9, 1}},
            {2, {9, 7}},
            {3, {9, 2}},
            {3, {9, 6}},
            {4, {9, 3}},
            {4, {9, 5}},
            {5, {9, 4}},
            {6, {7, 1}},
            {6, {7, 7}},
            {7, {6, 0}},
            {7, {6, 2}},
            {7, {6, 4}},
            {7, {6, 6}},
            {7, {6, 8}},
          ],
      log: []
    }
  end

  # init a new game
  def i3() do
    {i1(), i2(), 0}
  end

  #######
  # GET #
  #######

  # get a piece in the board
  def g0(a, i, j) do
    a 
    |-1> :array.get(i)
    |-1> :array.get(j)
  end

  # g0 variation
  def g00(a, i, j, x, f) do
    if f == 0, do: g0(a, x, j), else: g0(a, i, x) 
  end

  #########
  # PRINT #
  #########

  # print a single piece
  def p0({a, b}) do
    if b == 0 do
      case a do
        1 -> "车"
        2 -> "马"
        3 -> "相"
        4 -> "仕"
        5 -> "帅"
        6 -> "炮"
        7 -> "兵"
      end
      |> (fn x -> IO.ANSI.format([:blue, x], true) end).()
    else
      case a do
        1 -> "车"
        2 -> "马"
        3 -> "象"
        4 -> "士"
        5 -> "将"
        6 -> "炮"
        7 -> "卒"
      end
      |> (fn x -> IO.ANSI.format([:green, x], true) end).()
    end
    |> IO.write()
  end

  # print the board
  # iex> p1 i1
  def p1(a) do
    Enum.each(9..0, fn x -> 
      :array.get(x, a)
      |> :array.to_list()
      |> Enum.map(fn x -> 
        if x == {-1, -1} do
          IO.ANSI.format([:magenta, "十"], true) |> IO.write()
        else 
          p0(x)
        end
      end)
      IO.write("\n")
    end)
  end

  #############
  # ALGORITHM #
  #############

  # satisfiable moves

  ######################## t = 1

  def s000(i, j, x, f) do
    if f == 0, do: {x, j}, else: {i, x} 
  end

  def s00(a, i, j, o, f) do
    fn x, acc -> 
      cond do
        f == 0 && x == i -> {:cont, acc}
        f == 1 && x == j -> {:cont, acc}
        true ->
          case g00(a, i, j, x, f) do
            {-1, -1} -> {:cont, [s000(i, j, x, f) | acc]}
            {_, ^o} -> {:halt, acc}
            _ -> {:halt, [s000(i, j, x, f) | acc]}
          end
      end
    end
  end

  ######################## t = 2

  def s01(i, j) do
    cond do
      i < 0 || i > 9 || j < 0 || j > 8 -> false
      true -> true
    end
  end

  def s02(a, i, j) do
    s01(i, j) && {-1, -1} == g0(a, i, j)
  end

  def s030(x, i, j) do
    if x, do: [{i, j}], else: []
  end

  def s031(a, i, j, o) do
    case g0(a, i, j) do
      {-1, -1} -> true
      {_, ^o} -> false
      _ -> true
    end
    |-1> Kernel.&&(s01(i, j))
  end

  def s03(a, i, j, o) do
    s031(a, i, j, o) |> s030(i, j)
  end

  def s04(a, i, j, o, {f1, f2}, x) do
    case {f1, x} do
      {0, 0} -> s03(a, i + 1, j + 2 * f2, o)
      {0, _} -> s03(a, i - 1, j + 2 * f2, o)
      {_, 0} -> s03(a, i + 2 * f1, j + 1, o)
      _      -> s03(a, i + 2 * f1, j - 1, o)
    end
  end

  def s05(a, i, j, o, {f1, f2}) do
    if s02(a, i + f1, j + f2) do
      Enum.flat_map([0, 1], fn x -> s04(a, i, j, o, {f1, f2}, x) end)
    else
      []
    end
  end

  ######################## t = 3

  def s06(a, i, j, o) do
    cond do
      i < 5 && o == 0 -> true
      i > 4 && o == 1 -> true
      true -> false
    end
    |> Kernel.&&(s031(a, i, j, o))
    |> s030(i, j)
  end

  def s07(a, i, j, o, {f1, f2}) do
    if s02(a, i + f1, j + f2), do: s06(a, i + f1 * 2, j + f2 * 2, o), else: []
  end

  ######################## t = 4 and t = 5

  def s08(a, i, j, o) do
    cond do
      o == 0 && i < 3 && j > 2 && j < 6 -> true
      o == 1 && i > 6 && j > 2 && j < 6 -> true
      true -> false
    end
    |> Kernel.&&(s031(a, i, j, o))
    |> s030(i, j)
  end

  ######################## t = 7

  def s09(i, o) do
    cond do
      o == 0 && i < 5 -> [{1, 0}]
      o == 0 -> [{1, 0}, {0, 1}, {0, -1}]
      i > 4 -> [{-1, 0}]
      true -> [{-1, 0}, {0, 1}, {0, -1}]
    end
  end

  ######################## t = 6

  def s10(a, i, j, o, f) do
    fn x, {acc, s} -> 
      cond do
        f == 0 && x == i -> {:cont, {acc, s}}
        f == 1 && x == j -> {:cont, {acc, s}}
        true ->
          case {g00(a, i, j, x, f), s} do
            {{-1, -1}, true} -> {:cont, {[s000(i, j, x, f) | acc], s}}
            {_, true} -> {:cont, {acc, false}}
            {{-1, -1}, false} -> {:cont, {acc, s}}
            {{_, ^o}, false} -> {:halt, {acc, s}}
            _ -> {:halt, {[s000(i, j, x, f) | acc], s}}
          end
      end
    end
  end

  ######################## router

  def s0(a, i, j) do
    {t, o} = g0(a, i, j)
    case t do
      1 -> 
        [{i..0, 0}, {i..9, 0}, {j..0, 1}, {j..8, 1}]
        |> Enum.flat_map(fn {r, f} -> Enum.reduce_while(r, [], s00(a, i, j, o, f)) end)
      2 ->
        [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
        |> Enum.reduce([], fn x, acc -> s05(a, i, j, o, x) ++ acc end)
      3 -> 
        [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]
        |> Enum.reduce([], fn x, acc -> s07(a, i, j, o, x) ++ acc end)
      4 -> 
        [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]
        |> Enum.reduce([], fn {f1, f2}, acc -> s08(a, i + f1, j + f2, o) ++ acc end)
      5 -> 
        [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
        |> Enum.reduce([], fn {f1, f2}, acc -> s08(a, i + f1, j + f2, o) ++ acc end)
      7 -> 
        Enum.reduce(s09(i, o), [], fn {f1, f2}, acc -> s03(a, i + f1, j + f2, o) ++ acc end)
      6 -> 
        [{i..0, 0}, {i..9, 0}, {j..0, 1}, {j..8, 1}]
        |> Enum.flat_map(fn {r, f} -> Enum.reduce_while(r, {[], true}, s10(a, i, j, o, f)) |> elem(0) end)
      _ -> []
    end    
  end

  def s1(a, {i, j}, {i1, j1}) do
    Enum.any?(s0(a, i, j), fn x -> x == {i1, j1} end)
  end

  ########
  # MOVE #
  ########

  # m0 helper: set value

  def m00(a, i, j, x) do
    a
    |-1> :array.get(i)
    |-1> :array.set(j, x)
    |1> :array.set(i, a)
  end

  # m0 helper: move but not check

  def m01(a, {i, j}, {i1, j1}) do
    a
    |> m00(i, j, {-1, -1})
    |> m00(i1, j1, g0(a, i, j))
  end

  # move i, j to i1, j1: a

  def m0(a, p, p1) do
    if s1(a, p, p1) do
      m01(a, p, p1)
    else
      a
    end
  end

  # move i, j to i1, j1: d: l0/l1 and log

  def m1(d, o, p, p1) do
    d1 =
      Map.get(d, :"l#{o}")
      |> Enum.find(fn x -> elem(x, 1) == p end)
      |> elem(0)
      |0> (fn x -> Map.update!(d, :log, fn y -> [{x, p, p1} | y] end) end).()
    d1
    |> Map.get(:"l#{o}")
    |> Enum.map(fn x -> if elem(x, 1) == p, do: {elem(x, 0), p1}, else: x end)
    |-1> Map.put(d1, :"l#{o}")
  end

  #########
  # CHECK #
  #########

  def c00(d, o, t) do
    Map.get(d, :"l#{o}")
    |> Enum.find(fn x -> elem(x, 0) == t end)
    |> elem(1)
  end

  def c01(a, d, o) do
    c00(d, 1 - o, 5) |> (fn {i, j} -> m00(a, i, j, {1, 1 - o}) end).()
  end

  def c02(d, o) do
    [1, 2, 5, 6, 7] |> Enum.map(fn x -> c00(d, 1 - o, x) end)
  end

  def c0(a, d, o) do
    {c01(a, d, o), c00(d, o, 5)}
    |1> Enum.reduce_while(c02(d, o), fn p, {a, p1} -> 
      if s1(a, p, p1) do
        {:halt, false}
      else
        {:cont, {a, p1}}
      end
    end)
    |> is_tuple()
  end

  def c1(a, p = {i, j}, p1, d, o) do
    a1 = m0(a, p, p1)
    d1 = m1(d, o, p, p1)
    c0(a1, d1, o)
    |-1> Kernel.&&(s1(a, p, p1))
    |-1> Kernel.&&(o == g0(a, i, j) |> elem(1))
    |> (fn x -> {x, a1, d1} end).()
  end

  def c2({a, d, o}) do
    Map.get(d, :"l#{o}")
    |> Enum.any?(fn {_  , p = {i, j}} -> 
      s0(a, i, j) |> Enum.any?(fn p1 -> c1(a, p, p1, d, o) end)
    end)
  end

  ##########
  # ACTION #
  ##########


  # s = i3; p1 elem(s, 0)
  # {:ok, s = {a, d, o}} = a0(s, {2, 1}, {2, 4}); p1 a
  # {:ok, s = {a, d, o}} = a0(s, {7, 1}, {7, 4}); p1 a
  # {:ok, s = {a, d, o}} = a0(s, {2, 4}, {6, 4}); p1 a
  # {:ok, s = {a, d, o}} = a0(s, {9, 3}, {8, 4}); p1 a

  def a0(s = {a, d, o}, p, p1) do
    c1(a, p, p1, d, o)
    |> (fn {x, a1, d1} -> if x, do: {:ok, {a1, d1, 1 - o}}, else: {:error, s} end).()
  end

end
