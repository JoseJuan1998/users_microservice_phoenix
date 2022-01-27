defmodule Hangman.Accounts.User do
  use Ecto.Schema
  alias Hangman.Repo
  alias Hangman.Accounts.Credential
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :lastname, :string
    has_one :credential, Credential, on_delete: :delete_all

    timestamps()
  end

  @doc false
  defp get_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:id])
    |> validate_required([:id])
    |> get_user()
  end

  defp get_user(%{valid?: false} = changeset), do: changeset

  defp get_user(%{valid?: true} = changeset) do
    case Repo.get(__MODULE__, get_field(changeset, :id)) do
      nil -> add_error(changeset, :id, "User not found")
      user -> user |> Repo.preload(:credential)
    end
  end

  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :lastname])
    |> Ecto.Changeset.cast_assoc(:credential, with: &Credential.create_changeset/2)
    |> validate_required([:name, :lastname, :credential])
    |> validate_format(:name, ~r{^[a-zA-ZÀ-ÿ ]+$})
    |> validate_format(:lastname, ~r{^[a-zA-ZÀ-ÿ ]+$})
    |> setup_spaces()
  end

  def found_changeset(attrs) do
    attrs
    |> get_changeset()
  end

  def update_changeset(attrs) do
    attrs
    |> get_changeset()
    |> cast(attrs, [:name, :lastname])
    |> validate_required([:name, :lastname])
    |> validate_format(:name, ~r{^[a-zA-ZÀ-ÿ ]+$})
    |> validate_format(:lastname, ~r{^[a-zA-ZÀ-ÿ ]+$})
    |> setup_spaces()
  end

  def delete_changeset(attrs) do
    attrs
    |> get_changeset()
  end

  defp setup_spaces(%{valid?: false} = changeset), do: changeset

  defp setup_spaces(%{valid?: true, changes: %{name: name, lastname: lastname}} = changeset) do
    changeset
    |> put_change(:name, String.trim(name))
    |> put_change(:lastname, String.trim(lastname))
  end

  defp setup_spaces(%{valid?: true, changes: %{name: name}} = changeset) do
    changeset
    |> put_change(:name, String.trim(name))
  end

  defp setup_spaces(%{valid?: true, changes: %{lastname: lastname}} = changeset) do
    changeset
    |> put_change(:lastname, String.trim(lastname))
  end

  defp setup_spaces(%{valid?: true} = changeset), do: changeset
end
