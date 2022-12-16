defmodule AocHelpers.UnionRange do
  @moduledoc """
  Represents a union of ranges of step 1. Ranges
  with step -1 are allowed but converted to step 1.
  """

  defstruct [:ranges]

  def valid_range?(_x.._y//step) when step in [1, -1], do: true
  def valid_range?(_other), do: false

  @doc """
  Build a new UnionRange

  ## Examples

      iex> AocHelpers.UnionRange.new(1..2)
      %AocHelpers.UnionRange{ranges: [1..2]}

      iex> AocHelpers.UnionRange.new(2..1)
      %AocHelpers.UnionRange{ranges: [1..2]}

      iex> AocHelpers.UnionRange.new([4..6, 2..1])
      %AocHelpers.UnionRange{ranges: [1..2, 4..6]}

      iex> AocHelpers.UnionRange.new([4..6, 3..1])
      %AocHelpers.UnionRange{ranges: [1..6]}

      iex> AocHelpers.UnionRange.new([4..6, 2..1, -3..-1])
      %AocHelpers.UnionRange{ranges: [-3..-1, 1..2, 4..6]}
  """
  def new(_x.._y//step = range) when step in [1, -1], do: %__MODULE__{ranges: [normalize(range)]}

  def new(ranges) when is_list(ranges) do
    if Enum.all?(ranges, &valid_range?/1) do
      ranges
      |> Enum.map(&new/1)
      |> Enum.reduce(&union(&2, &1))
    else
      :error
    end
  end

  @doc """
  Union two UnionRanges or an UnionRange and a Range.
  ## Examples

      iex> AocHelpers.UnionRange.new(1..2) |>AocHelpers.UnionRange.union(4..5)
      %AocHelpers.UnionRange{ranges: [1..2, 4..5]}

      iex> AocHelpers.UnionRange.new(2..0) |> AocHelpers.UnionRange.union(AocHelpers.UnionRange.new([5..6, 1..3]))
      %AocHelpers.UnionRange{ranges: [0..3, 5..6]}

      iex> AocHelpers.UnionRange.new(1..2) |>AocHelpers.UnionRange.union(3..5)
      %AocHelpers.UnionRange{ranges: [1..5]}

      iex> AocHelpers.UnionRange.new([4..6, 2..1, -3..-1])
      %AocHelpers.UnionRange{ranges: [-3..-1, 1..2, 4..6]}
  """
  def union(%__MODULE__{} = union_range, _x.._y = range) do
    union(union_range, new(range))
  end

  def union(%__MODULE__{} = ur1, %__MODULE__{} = ur2) do
    new_ranges = Enum.reduce(ur2.ranges, ur1.ranges, &do_union(&2, &1))

    %__MODULE__{ranges: new_ranges}
  end

  defp do_union(remaining_list_of_ranges, range, previous_ranges \\ [])

  # Base case. Add the range to previous ranges and sort them
  defp do_union([] = _list_of_ranges, range, previous_ranges),
    do: [range | previous_ranges] |> Enum.sort_by(fn x.._y -> x end)

  defp do_union([next | tail], range, previous_ranges) do
    # If next and range can be mergeable, meaning that we can have
    # one range instead of two, we do it.
    if mergeable?(next, range) do
      do_union(tail ++ previous_ranges, union_of_two_ranges(range, next))
    else
      do_union(tail, range, [next | previous_ranges])
    end
  end

  # Mergeable means that either they are not disjoint
  # or that if they are disjoint, they can be merged
  # because they are adjacent (we only support ranges with step 1)
  defp mergeable?(_x1..y1, x2.._y2) when y1 + 1 == x2, do: true
  defp mergeable?(x1.._y1, _x2..y2) when y2 + 1 == x1, do: true
  defp mergeable?(r1, r2), do: not Range.disjoint?(r1, r2)

  # Merges two ranges. Assumes `mergeable?/2` returns true.
  defp union_of_two_ranges(_x1.._y1 = r1, _x2.._y2 = r2) do
    nx1..ny1 = normalize(r1)
    nx2..ny2 = normalize(r2)

    min(nx1, nx2)..max(ny1, ny2)
  end

  # Normalizes a range to step 1.
  defp normalize(x..y) when x > y, do: y..x
  defp normalize(other), do: other
end

defimpl Enumerable, for: AocHelpers.UnionRange do
  def count(union_range),
    do: {:ok, union_range.ranges |> Enum.map(&Range.size/1) |> Enum.sum()}

  def member?(union_range, element),
    do: {:ok, Enum.any?(union_range.ranges, &Enum.member?(&1, element))}

  def reduce(union_range, acc, fun) do
    Enum.reduce(union_range.ranges, acc, fn range, acc ->
      Enum.reduce(range, acc, fun)
    end)
  end

  def slice(_union_range), do: {:error, AocHelpers.UnionRange}
end
