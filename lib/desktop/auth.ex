defmodule Desktop.Auth do
  @moduledoc """
    Auth provider that ensures that only the wanted WebView can open an interact
    with the application. A token is generated and compared to ensure no other application
    can connect to the local webserver.
  """

  import Plug.Conn
  alias Desktop.OS
  @behaviour Plug

  @key :crypto.strong_rand_bytes(32)
  def login_key() do
    @key
    |> Base.encode32()
    |> String.trim_trailing("=")
  end

  def init([]), do: []

  def call(conn, _options \\ []) do
    conn = fetch_session(conn)

    case get_session(conn, :user) do
      nil -> require_auth(conn)
      true -> conn
    end
  end

  defp require_auth(conn) do
    conn = fetch_query_params(conn)

    if OS.mobile?() or login_key() == conn.query_params["k"] do
      put_session(conn, :user, true)
    else
      conn
      |> resp(401, "Unauthorized")
      |> halt()
    end
  end
end
