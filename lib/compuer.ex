defmodule Day9.Computer do
  use Bitwise
  alias Day9.Program

  def run(program) do
    tick(program)
  end

  def tick(program) do
    case Program.read(program) do
      instruction when instruction < 99 ->
        run_step(program, instruction, %{})

      instruction when instruction > 99 ->
        step_with_mode(program, instruction)

      _ ->
        program
    end
  end

  def step_with_mode(program, instruction) do
    opcode = rem(instruction, 100)

    code =
      instruction
      |> Integer.to_string()
      |> String.pad_leading(5, "0")

    param_mode = %{1 => :position, 2 => :position, 3 => :position}

    param_mode =
      case String.at(code, 0) do
        "1" -> Map.put(param_mode, 3, :immediate)
        "2" -> Map.put(param_mode, 3, :relative)
        _ -> param_mode
      end

    param_mode =
      case String.at(code, 1) do
        "1" -> Map.put(param_mode, 2, :immediate)
        "2" -> Map.put(param_mode, 2, :relative)
        _ -> param_mode
      end

    param_mode =
      case String.at(code, 2) do
        "1" -> Map.put(param_mode, 1, :immediate)
        "2" -> Map.put(param_mode, 1, :relative)
        _ -> param_mode
      end

    run_step(program, opcode, param_mode)
  end

  def run_step(program, opcode, param_mode) do
    case opcode do
      instruction when instruction == 1 ->
        add(program, param_mode)

      instruction when instruction == 2 ->
        mutiply(program, param_mode)

      instruction when instruction == 3 ->
        store(program, param_mode)

      instruction when instruction == 4 ->
        output(program, param_mode)

      instruction when instruction == 5 ->
        jump_if_true(program, param_mode)

      instruction when instruction == 6 ->
        jump_if_false(program, param_mode)

      instruction when instruction == 7 ->
        less_then(program, param_mode)

      instruction when instruction == 8 ->
        equals(program, param_mode)

      instruction when instruction == 9 ->
        adjust_relative_base(program, param_mode)

      instruction ->
        {:error, :invalid_opcode, instruction}
    end
  end

  def add(program, param_modes) do
    program
    |> Program.write(
      3,
      Program.read(program, 1, param_modes) + Program.read(program, 2, param_modes),
      param_modes
    )
    |> Program.move(4)
    |> tick()
  end

  def mutiply(program, param_modes) do
    program
    |> Program.write(
      3,
      Program.read(program, 1, param_modes) * Program.read(program, 2, param_modes),
      param_modes
    )
    |> Program.move(4)
    |> tick()
  end

  def store(program, param_modes) do
    {program, input} = Program.fetch_input(program)

    program
    |> Program.write(
      1,
      input,
      param_modes
    )
    |> Program.move(2)
    |> tick()
  end

  def jump_if_true(program, param_modes) do
    case Program.read(program, 1, param_modes) != 0 do
      true -> Program.move_to(program, Program.read(program, 2, param_modes))
      _ -> Program.move(program, 3)
    end
    |> tick()
  end

  def jump_if_false(program, param_modes) do
    case Program.read(program, 1, param_modes) == 0 do
      true -> Program.move_to(program, Program.read(program, 2, param_modes))
      _ -> Program.move(program, 3)
    end
    |> tick()
  end

  def less_then(program, param_modes) do
    case Program.read(program, 1, param_modes) < Program.read(program, 2, param_modes) do
      true ->
        program
        |> Program.write(3, 1, param_modes)

      _ ->
        program
        |> Program.write(3, 0, param_modes)
    end
    |> Program.move(4)
    |> tick()
  end

  def equals(program, param_modes) do
    case Program.read(program, 1, param_modes) == Program.read(program, 2, param_modes) do
      true ->
        program
        |> Program.write(3, 1, param_modes)

      _ ->
        program
        |> Program.write(3, 0, param_modes)
    end
    |> Program.move(4)
    |> tick()
  end

  def adjust_relative_base(program, param_modes) do
    program
    |> Program.adjust_relative(Program.read(program, 1, param_modes))
    |> Program.move(2)
    |> tick()
  end

  def output(%Program{mode: :first} = program, param_modes) do
    program
    |> Program.add_output(Program.read(program, 1, param_modes))
    |> Program.move(2)
  end

  def output(program, param_modes) do
    program
    |> Program.add_output(Program.read(program, 1, param_modes))
    |> Program.move(2)
    |> tick()
  end
end
