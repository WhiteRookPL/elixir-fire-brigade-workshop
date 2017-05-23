defmodule MetricsCollector.Schema.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  alias MetricsCollector.Schema.Organization

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organizations" do
    field :name, :string

    has_many :pages, MetricsCollector.Schema.Page

    timestamps()
  end

  @doc false
  def changeset(%Organization{} = organization, attrs) do
    organization
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
