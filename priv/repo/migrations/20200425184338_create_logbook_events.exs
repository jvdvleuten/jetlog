defmodule Jetlog.Repo.Migrations.CreateLogbookEvents do
  use Ecto.Migration

  def change do
    create table(:logbook_events) do
      add(:aggregate_id, :binary_id, null: false)
      add(:sequence, :integer, null: false)
      add(:body, :map, null: false)
      add(:timestamp, :utc_datetime_usec, null: false)
    end

    create(index(:logbook_events, [:aggregate_id, :sequence], unique: true))
  end
end
