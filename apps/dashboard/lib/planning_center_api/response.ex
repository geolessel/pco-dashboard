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
end
