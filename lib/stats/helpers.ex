defmodule CodingChallenge.Stats.Helpers do
  @moduledoc false

  def count_map_merger(map1, map2) do
    Map.merge(map1, map2, fn(_key, count1, count2) ->
      count1 + count2
    end)
  end

  def top_10_count_map(map) do
    map
    |> Enum.into([])
    |> Enum.sort_by(fn {_, count} -> count end, &>=/2)
    |> Enum.map(fn {value, _} -> value end)
    |> Enum.take(10)
  end
end
