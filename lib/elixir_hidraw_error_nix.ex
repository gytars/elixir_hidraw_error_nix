defmodule ElixirHidrawErrorNix do
  @moduledoc """
  Documentation for `ElixirHidrawErrorNix`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ElixirHidrawErrorNix.hello()
      :world

  """
  def hello do
    :world
  end

  def enumerate() do
    Hidraw.enumerate()
  end
end
