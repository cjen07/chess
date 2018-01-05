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

  def king_check({a, b, o}) do
    l0 = Map.get(b, :"l#{o}")
    l1 = Map.get(b, :"l#{1-o}")
    e0 = Enum.find(l0, fn x -> elem(x, 0) == 5 end)
    e1 = Enum.find(l1, fn x -> elem(x, 0) == 5 end)
    cond do
      is_nil(e0) -> :fail
      true ->
        {_, {i1, j1}} = e0
        {_, {i2, j2}} = e1
        mx = max(i1, i2)
        mi = min(i1, i2)
        cond do
          j1 == j2 && !Enum.any?(l0 ++ l1, fn {_, {i, j}} -> j == j1 && i > mi && i < mx end) -> :error
          true -> :ok            
        end
    end
  end

  def all({a, b, o}) do
    no = 1 - o
    l = Map.get(b, :"l#{o}")
    s = Enum.map(l, fn {_, {i, j}} -> s0(a, i, j) end)
    z = Enum.zip(l, s)
    Enum.map(z, fn x ->
      {{t, p1}, l} = x
      ll = Enum.map(l, fn p ->
        na = m0(a, p1, p)
        p1(na)
        IO.puts "\n"
        nb = m1(b, o, p1, p)
        IO.inspect nb
        {na, nb, no}
      end)
      kc = Enum.map(ll, fn x -> king_check(x) end)
      IO.inspect(kc)
      ll
    end)
    
  end

  def test_board() do
    b = empty_board()
    {b, %{l0: [], l1: [], log: []}, 0}
    |> put_piece(0, 5, 0, 5)
    |> put_piece(1, 5, 8, 4)
  end

  def test_board1() do
    b = empty_board()
    {b, %{l0: [], l1: [], log: []}, 0}
    |> put_piece(0, 5, 0, 5)
    |> put_piece(1, 5, 8, 4)
    |> put_piece(0, 1, 6, 4)
  end
end