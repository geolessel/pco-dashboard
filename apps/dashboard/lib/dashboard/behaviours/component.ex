defmodule Dashboard.Behaviours.Component do
  @callback data_sources() :: map()
  @callback fetch_data(state :: map()) :: map()
  @callback get(pid :: pid(), keyword :: atom() | String.t()) :: any()
  @callback get_all(pid :: pid()) :: any()
  @callback prepare_api_paths(data_sources :: map(), state :: map()) :: map()
  @callback process_data(state :: map()) :: map()
  @callback put_extra_assigns(state :: map()) :: map()
  @callback put_last_update(state :: map()) :: map()
end
