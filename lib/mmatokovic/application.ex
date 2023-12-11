defmodule Mmatokovic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MmatokovicWeb.Telemetry,
      # Start the Ecto repository
      Mmatokovic.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Mmatokovic.PubSub},
      # Start Finch
      {Finch, name: Mmatokovic.Finch},
      # Start the Endpoint (http/https)
      MmatokovicWeb.Endpoint
      # Start a worker by calling: Mmatokovic.Worker.start_link(arg)
      # {Mmatokovic.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mmatokovic.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MmatokovicWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
