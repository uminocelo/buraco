defmodule Buraco.Application do
  @moduledoc """
  Defines the OTP application entry point for Buraco.

  This module starts the root supervisor, which owns and supervises
  `Buraco.Server`.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Buraco.Server, []}
    ]

    opts = [strategy: :one_for_one, name: Buraco.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
