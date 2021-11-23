defmodule Hangman.Repo.Migrations.CreateEmailToken do
  use Ecto.Migration

  def change do
    create table(:email_tokens) do
      add :token, :string

      timestamps()
    end
  end
end
