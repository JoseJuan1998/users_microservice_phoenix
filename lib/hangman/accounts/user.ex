defmodule Hangman.Accounts.User do
  use Ecto.Schema
  alias Hangman.Repo
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    has_one :credential, Hangman.Accounts.Credential, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def get_changeset(attrs) do
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
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def found_changeset(attrs) do
    attrs
    |> get_changeset()
  end

  def update_changeset(attrs) do
    attrs
    |> get_changeset()
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def delete_changeset(attrs) do
    attrs
    |> get_changeset()
  end
end
