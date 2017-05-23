defmodule TreasureHunt.Bomb do
  @env Mix.env
  @app Mix.Project.config[:app]

  @compile {:autoload, false}
  @on_load :init

  # Internal API.

  def init() do
    path = Application.app_dir(@app, ["priv", to_string(@env), "bomb"])
    :ok = :erlang.load_nif(path, 0)
  end

  # Public API.

  def explode() do
    raise "NIF explode/0 not implemented"
  end
end