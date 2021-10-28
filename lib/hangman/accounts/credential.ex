defmodule Hangman.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credentials" do
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :admin, :boolean
    field :active, :boolean
    belongs_to :user, Hangman.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :admin, :active])
    |> validate_required([:email, :admin, :active])
    |> validate_format(:email, ~r{^[^@]+@[^@]+\.[a-zA-Z]+$})
    |> unique_constraint(:email)
  end

  def registration_changeset(struct, attrs \\ %{}) do
    struct
    |> changeset(attrs)
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_format(:password, ~r{^(?=\w*\d)(?=\w*[A-Z])(?=\w*[a-z])\S+$})
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> hash_password()
  end

  def hash_password(%{valid?: false} = changeset), do: changeset

  def hash_password(%{valid?: true, changes: %{password: pass}} = changeset) do
    put_change(changeset, :password_hash, Argon2.hash_pwd_salt(pass))
  end
end
