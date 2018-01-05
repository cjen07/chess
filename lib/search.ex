defmodule Search do
  import Chess
  def empty_board() do
    row = Enum.reduce(0..8, :array.new(9), fn x, acc ->
      :array.set(x, {-1, -1}, acc)
    end)
    Enum.reduce(0..9, :array.new(10), fn x, acc -> 
      :array.set(x, row, acc) 
    end)
  end

  def put_piece({a, b, c}, o, t, i, j) do
    {m00(a, i, j, {t, o}), Map.update!(b, :"l#{o}", fn x -> [{t, {i, j}} | x] end), c}
  end

  def read_board() do
    b = empty_board()
    {b, %{l0: [], l1: [], log: []}, 0}
    |> put_piece(0, 5, 0, 5)
    |> put_piece(0, 1, 5, 1)
    |> put_piece(0, 2, 7, 6)
    |> put_piece(1, 5, 8, 3)
    |> put_piece(1, 1, 2, 3)
    |> put_piece(1, 7, 1, 4)
  end

  def all({a, b, o}) do
    no = 1 - o
    l = Map.get(b, :"l#{o}")
    s = Enum.map(l, fn {_, {i, j}} -> s0(a, i, j) end)
    z = Enum.zip(l, s)
    Enum.map(z, fn x ->
      {{t, p1}, l} = x
      Enum.map(l, fn p ->
        na = m0(a, p1, p)
        p1(na)
        IO.puts "\n"
        nb = m1(b, o, p1, p)
        {na, nb, no}
      end)
    end)
    
  end
end