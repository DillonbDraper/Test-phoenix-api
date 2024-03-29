defmodule MyAppWeb.UserController do
  use MyAppWeb, :controller

  alias MyApp.Account
  alias MyApp.Account.User

  action_fallback MyAppWeb.FallbackController

  def index(conn, _params) do
    users = Account.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Account.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Account.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Account.get_user!(id)

    with {:ok, %User{} = user} <- Account.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Account.get_user!(id)

    with {:ok, %User{}} <- Account.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
        case Account.authenticate_user(email, password) do
          {:ok, user} ->
            conn
            |> put_status(:ok)
            |> put_view(MyAppWeb.UserView)
            |> render("sign_in.json", user: user)

          {:error, message} ->
            conn
            |> put_status(:unauthorized)
            |> put_view(MyAppWeb.ErrorView)
            |> render("401.json", message: message)
        end
      end

end
