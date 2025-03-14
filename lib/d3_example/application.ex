defmodule D3Example.Application do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: D3Example.Router, options: [port: 4000]}
    ]

    opts = [strategy: :one_for_one, name: D3Example.Supervisor]
    Supervisor.start_link(children, opts)
  end
end