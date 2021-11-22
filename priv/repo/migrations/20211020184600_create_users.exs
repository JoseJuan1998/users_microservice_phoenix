defmodule Hangman.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :lastname, :string
      timestamps()
    end
  end
end
