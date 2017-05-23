defmodule MagicEightBall.Logic do
  @env Mix.env
  @app Mix.Project.config[:app]

  @compile {:autoload, false}
  @on_load :init

  # Internal API.

  def init() do
    path = Application.app_dir(@app, ["priv", to_string(@env), "magic_eight_ball_logic"])
    :ok = :erlang.load_nif(path, 0)
  end

  # Public API.

  @spec question(String.t) :: :not_a_question | {:ok, String.t}
  def question(_question) do
    raise "NIF question/1 not implemented"
  end
end