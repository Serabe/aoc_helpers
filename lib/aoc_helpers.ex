defmodule AocHelpers do
  @moduledoc """
  Documentation for `AocHelpers`.
  """

  @doc """
  Returns the input given the year and day
  """
  @spec get_input(year :: number(), day :: number(), cookie :: String.t()) :: String.t()
  def get_input(year, day, cookie \\ nil) do
    get_input_request(year, day, cookie)
    |> Map.get(:body)
  end

  @doc """
  Returns the input HTTPoison request given the year and day
  """
  @spec get_input_request(year :: number(), day :: number, cookie :: String.t()) ::
          HTTPoison.Response.t()
  def get_input_request(year, day, cookie \\ nil) do
    url(year, day)
    |> HTTPoison.get!(%{}, hackney: build_cookie(cookie))
  end

  defp build_cookie(nil), do: System.fetch_env!("AOC_COOKIE") |> build_cookie()
  defp build_cookie(cookie), do: [cookie: "session=" <> cookie]
  defp url(year, day), do: "https://adventofcode.com/#{year}/day/#{day}/input"
end
