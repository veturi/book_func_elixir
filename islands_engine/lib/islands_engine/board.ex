defmodule IslandsEngine.Board do
  @moduledoc """
  Board represents the game board.
  It contains player's islands, but it also brokers messages for them.
  Sometimes it will need to reference individual islands, like
  when it's checking to see if one is forested.
  Somethimes it will need to enumerate over all the islands, like
  when it's checking to see if the game is over.

  Board is an orchestrator as well as an interface for actions that involve islands.

  The actions board handles include:
  - Positioning islands
  - Ensuring that all islands are positioned
  - Guessing coordinates

  A player’s own board acts as an interface. It’s the front door to the data and functions that make up the game.
  """

  alias IslandsEngine.Island
  alias IslandsEngine.Coordinate

  @doc """
  Returns a new Board.

  We would not need this but to keep module APIs consistent
  we want to define similar functions for all modules.
  """
  def new(), do: %{}

  def position_island(board, key, %Island{} = island) do
    case overlaps_existing_island?(board, key, island) do
      true -> {:error, :overlapping_island}
      false -> Map.put(board, key, island)
    end
  end

  defp overlaps_existing_island?(board, new_key, new_island) do
    Enum.any?(board, fn {key, island} ->
      key != new_key and Island.overlaps?(island, new_island)
    end)
  end

  def all_island_positioned?(board) do
    Enum.all?(Island.types, &(Map.has_key?(board, &1)))
  end

  def guess(board, %Coordinate{} = coordinate) do
    board
    |> check_all_islands(coordinate)
    |> guess_response(board)
  end

  defp check_all_islands(board, coordinate) do
    Enum.find_value(board, :miss, fn {key, island} ->
      case Island.guess(island, coordinate) do
        {:hit, island} -> {key, island}
        :miss -> false
      end
    end)
  end

  defp guess_response({key, island}, board) do
    board = %{board | key => island}
    {:hit, forest_check(board, key), win_check(board), board}
  end
  defp guess_response(:miss, board) do
    {:miss, :none, :no_win, board}
  end

  defp forest_check(board, key) do
    case forested?(board, key) do
      true -> key
      false -> :none
    end
  end

  def forested?(board, key) do
    board
    |> Map.fetch!(key)
    |> Island.forested?()
  end

  defp win_check(board) do
    case all_forested?(board) do
      true -> :win
      false -> :no_win
    end
  end

  defp all_forested?(board) do
    Enum.all?(board, fn {_key, island} -> Island.forested?(island) end)
  end
end
