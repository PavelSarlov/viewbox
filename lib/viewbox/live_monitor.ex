defmodule Viewbox.LiveMonitor do
  use GenServer

  def monitor(view_module, view_meta) do
    pid = GenServer.whereis({:global, __MODULE__})
    GenServer.call(pid, {:monitor, view_module, view_meta})
  end

  def demonitor() do
    pid = GenServer.whereis({:global, __MODULE__})
    GenServer.call(pid, :demonitor)
  end

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg, name: {:global, __MODULE__})
  end

  @impl true
  def init(_) do
    {:ok, %{views: %{}}}
  end

  @impl true
  def handle_call(
        {:monitor, view_module, view_meta},
        {view_pid, _ref},
        %{views: views} = state
      ) do
    view_ref = Process.monitor(view_pid)
    {:reply, :ok, %{state | views: Map.put(views, view_pid, {view_module, view_meta, view_ref})}}
  end

  def handle_call(:demonitor, {view_pid, _ref}, state) do
    {{_view_module, _view_meta, view_ref}, new_views} = Map.pop(state.views, view_pid)
    :erlang.demonitor(view_ref)
    new_state = %{state | views: new_views}
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, view_pid, reason}, state) do
    case Map.pop(state.views, view_pid) do
      {{view_module, view_meta, _view_ref}, new_views} ->
        Task.async(fn -> view_module.unmount(reason, view_meta) end)
        {:noreply, %{state | views: new_views}}

      _ ->
        {:noreply, state}
    end
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
