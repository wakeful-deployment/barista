defmodule Api.ClusterController do
  use Api.Web, :controller

  def get_services do
    res = HTTPoison.get("http://localhost:8500/v1/catalog/services")

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      _ -> {:error, "error fetching services"}
    end
  end

  def decode({:ok, body}) do
    Poison.decode(body)
  end
  def decode(error), do: error

  def show(conn, _params) do
    case decode(get_services) do
      {:ok, services} ->
        json conn, %{services: services}
      _ ->
        conn
        |> put_status(500)
        |> json(%{error: "sorry http failed"})
    end
  end
end
