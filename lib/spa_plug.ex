defmodule SpaPlug do
  @moduledoc """
  A plug for serving single page apps.

  It works by using a second `Plug.Static` plug, and relies on rewriting the request `conn.path_info`, so this may have side effects on your pipelines.
  For example, to log original incoming request paths you may want to put your logging plug before `SpaPlug`.
  It inherits all the options from `Plug.Static`, so these two are also required:

    * `:at` - the request url path to host the assets at, usually "/"

    * `:from` - file path of the assets

  New options:

    * `:except` - a list of url prefixes to be excluded, incoming requests matching any one of the list will not fallback to the `:index` if the file is not found. The paths should be urlencoded. Defaults to `["/api", "/dev", "/metrics"]`.

    * `:index_merge_opts` - `Plug.Static` options except `:only` for the index specifically, to be merged with base options and overriding them. Note that the merge is not deep merge (`Keyword.merge/2`). Defaults to `[]`.

    * `:index` - path of the index file relative to the `:from` for the index. Defaults to `"index.html"`.

  And other options from `Plug.Static`:

    * `:encodings`, `:gzip`, `:brotli`
    * `:cache_control_for_etags`
    * `:etag_generation`
    * `:cache_control_for_vsn_requests`
    * `:only`
    * `:headers`
    * `:content_types`

  Please consult hexdocs for the details.

  """

  @behaviour Plug
  @default_index "index.html"
  @default_except ["/api", "/dev", "/metrics"]
  @allowed_methods ~w(GET HEAD)

  @impl true
  def init(opts) do
    except = Keyword.get(opts, :except, @default_except) |> Enum.map(&Plug.Router.Utils.split/1)

    merged = Keyword.merge(opts, Keyword.get(opts, :index_merge_opts, []))
    at = Keyword.get(merged, :at) |> Plug.Router.Utils.split()

    index = [Keyword.get(opts, :index, @default_index)]

    {
      Plug.Static.init(opts),
      Plug.Static.init(Keyword.merge(merged, only: index)),
      except,
      at ++ index
    }
  end

  @impl true
  def call(conn = %Plug.Conn{method: m}, {plug1, plug2, except, index}) when m in @allowed_methods do
    with %{halted: false} = conn <- Plug.Static.call(conn, plug1),
         conn <- not_found(conn, except, index),
         %{halted: false} = conn <- Plug.Static.call(conn, plug2),
         do: conn
  end

  def call(conn, _opts) do
    conn
  end

  defp not_found(conn, except, index) do
    if conn.path_info == [] or
         not Enum.any?(except, &List.starts_with?(conn.path_info, &1)) do
      %{conn | path_info: index}
    else
      conn
    end
  end
end
