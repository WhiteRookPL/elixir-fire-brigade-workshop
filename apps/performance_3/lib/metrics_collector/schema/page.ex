defmodule MetricsCollector.Schema.Page do
  use Ecto.Schema
  import Ecto.Changeset
  alias MetricsCollector.Schema.Page

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pages" do
    field :url, :string

    has_many :tracking_points, MetricsCollector.Schema.TrackingPoint
    belongs_to :organization, MetricsCollector.Schema.Organization

    timestamps()
  end

  def changeset(%Page{} = page, attrs) do
    page
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
