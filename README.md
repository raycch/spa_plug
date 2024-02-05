# SpaPlug

[![Version](https://img.shields.io/hexpm/v/spa_plug.svg)](https://hex.pm/packages/spa_plug)
[![Hex Docs](https://img.shields.io/badge/hex-docs-purple.svg)](https://hexdocs.pm/spa_plug/)
[![License](https://img.shields.io/badge/License-Apache%202.0-orange.svg)](https://opensource.org/license/apache-2-0/)

A [plug](http://github.com/elixir-lang/plug) for serving single page apps directly from your Elixir application.

## Installation

Add `spa_plug` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    # ...
    {:spa_plug, "~> 1.0.0"}
  ]
end
```
## Usage

 If using Phoenix, you can put it in `lib/your_app/endpoint.ex`. Order is important for plugs or middlewares in other frameworks. The same applies to `SpaPlug`, as it rewrites the `Plug.conn` as necessary. Also, keep in mind that potentially it can take over other routes. By default, `"/api"`, `"/dev"` and `"/metrics"` are already excluded, adjust `:except` for your specific needs or rearrange your plugs.

```elixir
  plug SpaPlug,
    at: "/",
    from: :your_app,
    only: YourAppWeb.static_paths(),
    # example: always up-to-date index page with immutable assets
    # ref: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control#up-to-date_contents_always

    # your assets should be requested with the query param "vsn", or include the headers below
    # headers: [{"cache-control": "max-age=31536000, immutable"}],

    # this assumes your index.html is in the default priv/static directory as well, otherwise pass :from in :index_merge_opts
    index_merge_opts: [headers: [{"cache-control", "no-cache"}]]
```

## Documentation

See https://hex.pm/packages/spa_plug.

## Compatibility

The plug should be tested against the plug version listed in `mix.exs`.

## Rationale

Without the SSR on Node.js platform you will need to host your React or Vue.js apps as static assets. The typical solution would be to put a reverse proxy like Nginx in front. However, if you don't want to do it for some reason, there are no built-in or third party libraries for doing this. Plain `Plug.Static` would only serve the whole directory as it is.

Alternatively you can also just use catch all requests and call `Plug.Conn.send_file/5` or `Phoenix.Controller.render/2` in your router or controller, but it is not as performant or flexible despite the inconvenience. With this plug your phoenix application can keep the same docker image from `mix phx.gen.release --docker`. It works standalone or with a CDN as well, just point it to your servers as origin.

