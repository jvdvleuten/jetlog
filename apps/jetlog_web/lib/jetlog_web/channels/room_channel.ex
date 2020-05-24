defmodule JetlogWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", message, socket) do
    IO.inspect(["Joined channel", message])
    send(self(), {:after_joined, message})
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    IO.puts("Error channel")
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info({:after_joined, msg}, socket) do
    IO.inspect(msg)
    broadcast!(socket, "new_user", %{username: "hoi"})
    {:noreply, socket}
  end

  def terminate(reason, _socket) do
    IO.inspect(["Left channel", reason])
    :ok
  end
end
