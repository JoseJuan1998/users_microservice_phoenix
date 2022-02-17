import Ecto.Changeset

changeset = Hangman.Accounts.change_user(%Hangman.Accounts.User{}, %{"name" => "Jose Luis", "lastname" => "Pamplona Stoever", "credential" => %{"email" => "luis@cordage.io"}})
admin_change = changeset.changes.credential |> put_change(:admin, true)
new_changeset = changeset |> put_change(:credential, admin_change)
new_changeset |> Hangman.Repo.insert()
Hangman.Accounts.update_password(%{"id" => "1", "password" => "CoDeGreenHouse2022", "password_confirmation" => "CoDeGreenHouse2022"})
