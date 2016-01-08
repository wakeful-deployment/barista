defmodule Api.ClusterController do
  use Api.Web, :controller

  def get_services do
    res = HTTPoison.get("http://localhost:8500/v1/catalog/services")

    case res do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} -> {:ok, body}
      _ -> {:error}
    end
  end

  def show(conn, _params) do
    case get_services do
      {:ok, body} ->
        case Poison.decode(body) do
          {:ok, services} ->
            json conn, %{services: services}
          _ ->
            conn
            |> put_status(500)
            |> json(%{error: "sorry"})
        end
      _ ->
        conn
        |> put_status(500)
        |> json(%{error: "sorry"})
    end
  end
end
