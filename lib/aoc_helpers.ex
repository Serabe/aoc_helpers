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
    {:ok, {{_protocol, 200, 'OK'}, headers, body}} =
      :httpc.request(
        :get,
        {'https://adventofcode.com/#{year}/day/#{day}/input',
         build_cookie(cookie)},
        [],
        []
      )
    %{
      headers: parse_headers(headers),
      body: to_string(body)
    }
  end

  @doc """
  Streams the input as a series of lines.

  Options:

  - trim, optional, defaults to true.
  """
  def stream_lines(input, opts \\ [trim: true]) do
    String.splitter(input, "\n", opts)
  end

  @doc """
  Streams the input as a series of integers.

  Options:

  - base, optional, defaults to 10. Base for parsing the digits.
  - trim, optional, defaults to true. For the splitting process.
  - whiteline, optional, defaults to "". Value for empty lines.
  """
  def stream_integers(input, opts \\ []) do
    base = Keyword.get(opts, :base, 10)
    trim = Keyword.get(opts, :trim, true)
    whiteline = Keyword.get(opts, :whiteline, "")

    input
    |> stream_lines(trim: trim)
    |> Stream.map(fn
      "" -> whiteline
      n -> String.to_integer(n, base)
    end)
  end

  defp parse_headers(headers, parsed \\ %{})
  defp parse_headers([], parsed), do: parsed
  defp parse_headers([{key, value} | rest], parsed) do
    parse_headers(rest, Map.put(parsed, to_string(key), to_string(value)))
  end

  defp build_cookie(nil), do: System.fetch_env!("AOC_COOKIE") |> build_cookie()
  defp build_cookie(cookie), do: [{'cookie', String.to_charlist("session=" <> cookie)}]
end
