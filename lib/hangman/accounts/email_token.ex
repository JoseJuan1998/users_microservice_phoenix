defmodule Hangman.Accounts.EmailToken do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hangman.Repo

  schema "email_tokens" do
    field :token, :string, size: 500

    timestamps()
  end

  defp get_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:token])
    |> validate_required([:token])
    |> get_token()
  end

  # coveralls-ignore-start
  defp get_token(%{valid?: false} = changeset), do: changeset
  # coveralls-ignore-stop

  defp get_token(%{valid?: true} = changeset) do
    case Repo.get_by(__MODULE__, token: get_field(changeset, :token)) do
      nil -> add_error(changeset, :token, "Token not found")
      token -> token
    end
  end

  def create_changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:token])
    |> validate_required([:token])
  end

  def delete_changeset(attrs) do
    attrs
    |> get_changeset()
  end
end
