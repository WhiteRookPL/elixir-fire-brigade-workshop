defmodule MetricsCollector.Repo.Migrations.CreatePages do
  use Ecto.Migration

  def change do
    create table(:pages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :url, :string
      add :organization_id, references(:organizations, type: :binary_id)

      timestamps()
    end

    create index(:pages, [:organization_id])
  end
end
