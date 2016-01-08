defmodule Api.ClusterController do
  use Api.Web, :controller

  def show(conn, _params) do
    json conn, %{name: "Hello"}
  end
end
