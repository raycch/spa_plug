defmodule SpaPlugTest do
  use ExUnit.Case, async: false
  use Plug.Test
  import Mock
  doctest SpaPlug

  @default_opts [
    at: "/",
    from: Path.expand("fixtures", __DIR__)
  ]

  defp call(conn, opts \\ []) do
    opts =
      @default_opts
      |> Keyword.merge(opts)
      |> SpaPlug.init()

    with %Plug.Conn{halted: false} = conn <- SpaPlug.call(conn, opts),
         do: no_match(conn)
  end

  defp no_match(conn), do: Plug.Conn.send_resp(conn, 404, "not found")

  test "serves the file when given it's path" do
    conn = call(conn(:get, "/dir/second.txt"))
    assert conn.status == 200
    assert conn.resp_body == "dir/second.txt"
  end

  test "leads empty path to the default file" do
    conn = call(conn(:get, ""))
    assert conn.status == 200
    assert conn.resp_body == "index.html"
  end

  test "leads root path to the default file" do
    conn = call(conn(:get, "/"))
    assert conn.status == 200
    assert conn.resp_body == "index.html"
  end

  test "serves the default file when given its path" do
    conn = call(conn(:get, "/index.html"))
    assert conn.status == 200
    assert conn.resp_body == "index.html"
  end

  test "serves the user chosen default file" do
    conn = call(conn(:get, "/"), index: "first.txt")
    assert conn.status == 200
    assert conn.resp_body == "first.txt"
  end

  test "fallbacks to default file when no match" do
    conn = call(conn(:get, "/a/b"))
    assert conn.status == 200
    assert conn.resp_body == "index.html"
  end

  test "does not fallback when the path matches :except " do
    conn = call(conn(:get, "/a/b"), except: ["a"])
    assert conn.status == 404
    assert conn.resp_body == "not found"
  end

  test "works with urlencoded :except" do
    conn =
      call(conn(:get, "/dir%20with%20spaces/not_third.txt"), except: ["dir%20with%20spaces"])

    assert conn.status == 404
    assert conn.resp_body == "not found"
  end

  test "serves the default file at a different path" do
    conn = call(conn(:get, "/app"), index: "first.txt", index_merge_opts: [at: "/app"])
    assert conn.status == 200
    assert conn.resp_body == "first.txt"
  end

  test "ignores index's :only opt" do
    conn =
      call(conn(:get, "/app"),
        index: "first.txt",
        index_merge_opts: [at: "/app", only: "no_effect"]
      )

    assert conn.status == 200
    assert conn.resp_body == "first.txt"
  end

  test "ignores requests with disallowed methods" do
    conn =
      call(conn(:post, "/"))

    assert conn.status == 404
    assert conn.resp_body == "not found"
  end

  test "calls static plug with right arguments" do
    with_mock Plug.Static, init: fn _opts -> :ok end do
      opts =
        @default_opts
        |> Keyword.merge(index_merge_opts: [at: "/a"])

      SpaPlug.init(opts)

      expected =
        Keyword.merge(@default_opts, at: "/a", index_merge_opts: [at: "/a"], only: ["index.html"])

      [
        {_, {_, _, [received1]}, _},
        {_, {_, _, [received2]}, _}
      ] = call_history(Plug.Static)

      assert Keyword.equal?(received1, opts)
      assert Keyword.equal?(received2, expected)
    end
  end
end
