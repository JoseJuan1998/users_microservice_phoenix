defmodule Hangman.Repo.Migrations.CreateEmailToken do
  use Ecto.Migration

  def change do
    create table(:email_tokens) do
      add :token, :string, size: 500

      timestamps()
    end
  end
end
