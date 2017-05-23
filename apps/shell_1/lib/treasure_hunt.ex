defmodule TreasureHunt do
  use Application

  def start(_type, _args) do
    case Node.self() do
      :'treasure_hunt_node_1@127.0.0.1' ->
        nil

      node_name ->
        regex = ~r/treasure_hunt_node_(?<node_number>[\d]+)@127\.0\.0\.1$/

        captures = Regex.named_captures(regex, Atom.to_string(node_name))
        node_number = String.to_integer(captures["node_number"])

        Node.connect(String.to_atom("treasure_hunt_node_#{node_number - 1}@127.0.0.1"))
    end

    TreasureHunt.Supervisor.start_link()
  end

  def open_chest() do
    TreasureHunt.Chest.open()
  end
end
