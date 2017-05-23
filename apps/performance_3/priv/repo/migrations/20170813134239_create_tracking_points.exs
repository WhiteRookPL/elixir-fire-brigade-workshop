defmodule MetricsCollector.Repo.Migrations.CreateTrackingPoints do
  use Ecto.Migration

  def change do
    create table(:tracking_points, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_agent, :string
      add :content, :map
      add :page_id, references(:pages, type: :binary_id)

      timestamps()
    end

    create index(:tracking_points, [:page_id])
  end
end
