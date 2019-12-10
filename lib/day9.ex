defmodule Day9 do
  alias Day9.{Computer, Program, Input}

  def part1() do
    Program.new(Input.input(), :once, [1])
    |> Computer.run()
    |> Program.fetch_output()
  end

  def part2() do
    Program.new(Input.input(), :once, [2])
    |> Computer.run()
    |> Program.fetch_output()
  end
end
