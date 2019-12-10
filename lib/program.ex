defmodule Day9.Program do
  use Bitwise

  defstruct [:memory, :pos, :inputs, :outputs, :mode, :relative_base]

  def new(instructions, mode) when is_list(instructions) do
    %__MODULE__{
      memory: instructions_to_memory(instructions),
      pos: 0,
      inputs: [],
      outputs: [],
      mode: mode,
      relative_base: 0
    }
  end

  def new(instructions, mode, inputs) when is_list(instructions) do
    %__MODULE__{
      memory: instructions_to_memory(instructions),
      pos: 0,
      inputs: inputs,
      outputs: [],
      mode: mode,
      relative_base: 0
    }
  end

  defp instructions_to_memory(instructions) do
    {_, memory} =
      Enum.reduce(instructions, {0, %{}}, fn instruction, {location, memory} ->
        {location + 1, Map.put(memory, location, instruction)}
      end)

    memory
  end

  def move(%__MODULE__{pos: pos} = program, offset) when pos + offset >= 0 do
    %{program | pos: pos + offset}
  end

  def move_to(%__MODULE__{} = program, pos) when pos >= 0 do
    %{program | pos: pos}
  end

  def write(%__MODULE__{memory: memory} = program, at, value) do
    %{program | memory: Map.put(memory, at, value)}
  end

  def write(
        %__MODULE__{memory: memory, relative_base: relative_base} = program,
        offset,
        value,
        param_modes
      ) do
    case Map.get(param_modes, offset) do
      :relative ->
        %{program | memory: Map.put(memory, relative_base + read(program, offset), value)}

      _ ->
        %{program | memory: Map.put(memory, read(program, offset), value)}
    end
  end

  def read(%__MODULE__{memory: memory, pos: pos}) do
    Map.get(memory, pos, 0)
  end

  def read(%__MODULE__{memory: memory, pos: pos}, offset) do
    Map.get(memory, pos + offset, 0)
  end

  def read(%__MODULE__{memory: memory, pos: pos, relative_base: relative_base}, offset, mode) do
    case Map.get(mode, offset, :position) do
      :position ->
        Map.get(memory, Map.get(memory, pos + offset, 0), 0)

      :immediate ->
        Map.get(memory, pos + offset, 0)

      :relative ->
        Map.get(memory, relative_base + Map.get(memory, pos + offset, 0), 0)
    end
  end

  def add_input(%__MODULE__{inputs: inputs} = program, input) do
    %{program | inputs: inputs ++ [input]}
  end

  def fetch_input(%__MODULE__{inputs: [next | rest]} = program) do
    {%{program | inputs: rest}, next}
  end

  def fetch_input(%__MODULE__{inputs: []} = program) do
    {program, nil}
  end

  def add_output(%__MODULE__{outputs: outputs} = program, output) do
    %{program | outputs: [output] ++ outputs}
  end

  def fetch_output(%__MODULE__{outputs: outputs}) do
    outputs
  end

  def clear_outputs(%__MODULE__{} = program) do
    %{program | outputs: []}
  end

  def adjust_relative(%__MODULE__{relative_base: relative_base} = program, adjustment)
      when relative_base + adjustment >= 0 do
    %{program | relative_base: relative_base + adjustment}
  end
end
