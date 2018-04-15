defmodule Test do

  defmodule(A, do: defstruct([:x]))
  defmodule(B, do: defstruct([:x, :y]))
  defmodule(C, do: defstruct([:x, :y, :z]))

  @n 100_000

  def test(n \\ @n) do
    x = t1(n)
    y = t2(n)
    IO.puts("T1: #{inspect x}, T2: #{inspect y} -> T1/T2 = #{x/y}")
  end

  def t1(n \\ @n), do: measure(fn -> run(:t1, n) end)
  def t2(n \\ @n), do: measure(fn -> run(:t2, n) end)

  def measure(function) do
    function
    |> :timer.tc
    |> elem(0)
    |> Kernel./(1_000_000)
  end

  def profile(t, n \\ @n) do
    :fprof.apply(&run/2, [t, n])
    :fprof.profile()
    :fprof.analyse()
  end

  defp run(:t1, n) do
    for i <- 1..n do
      make_command_gen(:a, [x: i+1])
      make_command_gen(:b, [x: i+1, y: i+2])
      make_command_gen(:c, [x: i+1, y: i+2, z: i+3])
    end
  end

  defp run(:t2, n) do
    for i <- 1..n do
      make_command(:a, i+1)
      make_command(:b, i+1, i+2)
      make_command(:c, i+1, i+2, i+3)
    end
  end

  defp make_command_gen(command_id, args) do
    command_string = command_id |> Atom.to_string |> Macro.camelize
    command_atom = String.to_atom("Elixir.Test.#{command_string}")
    struct(command_atom, args)
  end

  defp make_command(:a, x),       do: %A{x: x}
  defp make_command(:b, x, y),    do: %B{x: x, y: y}
  defp make_command(:c, x, y, z), do: %C{x: x, y: y, z: z}

end
