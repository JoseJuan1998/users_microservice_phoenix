defmodule Hangman.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hangman.Repo



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
  defp get_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id])
    |> validate_required([:id])
    |> get_credential()
  end

  defp get_credential(changeset) do
    case changeset.valid? do
      true ->
        case Repo.get(__MODULE__, get_field(changeset, :id)) do
          nil -> add_error(changeset, :id, "Credential not found")
          credential -> credential |> Repo.preload(:user)
        end
      false -> changeset
    end
  end

  def get_changeset_email(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> get_credential_email()
  end

  defp get_credential_email(changeset) do
    case changeset.valid? do
      true ->
        case Repo.get_by(__MODULE__, email: get_field(changeset, :email)) do
          nil -> add_error(changeset, :email, "Credential not found")
          credential -> credential |> Repo.preload(:user)
        end
      false -> changeset
    end
  end

  @doc false
  def create_changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r{^[^@]+@[^@]+\.[a-zA-Z]+$})
    |> unique_constraint(:email, message: "Email already exist")
    |> setup_create()
  end

  def password_changeset(attrs \\ %{}) do
    attrs
    |> get_changeset()
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_format(:password, ~r{^(?=\w*\d)(?=\w*[A-Z])(?=\w*[a-z])\S+$})
    |> validate_length(:password, min: 8)
    |> validate_confirmation(:password)
    |> setup_password()
  end

  defp setup_password(%{valid?: false} = changeset), do: changeset

  defp setup_password(%{valid?: true, changes: %{password: pass}} = changeset) do
    changeset
    |> put_change(:password_hash, Argon2.hash_pwd_salt(pass))
    |> put_change(:active, true)
  end

  defp setup_create(%{valid?: false} = changeset), do: changeset

  defp setup_create(%{valid?: true} = changeset) do
    changeset
    |>put_change(:admin, false)
    |>put_change(:active, false)
  end
end
