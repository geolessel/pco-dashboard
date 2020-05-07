defmodule Dashboard.PlanningCenterApi.Response do
  defstruct [:status, :body, :headers]

  def from_mint({:ok, %{data: data, headers: headers, status: status}}) do
    %__MODULE__{
      status: status,
      body: Jason.decode!(data),
      headers: Enum.into(headers, %{})
    }
  end

  def from_mint({:ok, %{headers: headers, status: status}}) do
    %__MODULE__{
      status: status,
      headers: Enum.into(headers, %{})
    }
  end

  def dig(data, dig_path) when is_map(data) and is_list(dig_path) do
    dig_deeper(data, dig_path)
  end

  defp dig_deeper(map, []), do: map

  defp dig_deeper(map, [dig_key | rest]), do: dig_deeper(Map.get(map, dig_key, %{}), rest)
end
