defmodule MetricsCollector.Schema.TrackingPoint do
  use Ecto.Schema
  import Ecto.Changeset
  alias MetricsCollector.Schema.TrackingPoint

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tracking_points" do
    field :user_agent, :string
    field :content, :map

    belongs_to :page, MetricsCollector.Schema.Page

    timestamps()
  end

  @doc false
  def changeset(%TrackingPoint{} = tracking_point, attrs) do
    tracking_point
    |> cast(attrs, [:user_agent, :content])
    |> validate_required([:user_agent, :content])
  end
end
