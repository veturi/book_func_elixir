defmodule IslandsEngine.Guesses do
  alias __MODULE__
  alias IslandsEngine.Coordinate

  @enforce_keys [:hits, :misses]
  defstruct [:hits, :misses]

  @doc """
  Create a new Guesses struct with empty hits and misses MapSets
  MapSet is a data structure for sets that guarantees uniqueness of its elements
  """
  def new() do
    %Guesses{ hits: MapSet.new(), misses: MapSet.new() }
  end

  def add(%Guesses{} = guesses, :hit, %Coordinate{} = coordinate) do
    update_in(guesses.hits, &MapSet.put(&1, coordinate))
  end

  def add(%Guesses{} = guesses, :miss, %Coordinate{} = coordinate) do
    update_in(guesses.misses, &MapSet.put(&1, coordinate))
  end
end
