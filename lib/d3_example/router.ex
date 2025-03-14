defmodule D3Example.Router do
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason

  plug :match
  plug :dispatch

  get "/" do
    html = File.read!(Path.join([__DIR__, "templates", "index.html"]))

    conn
    |> Plug.Conn.put_resp_content_type("text/html")
    |> send_resp(200, html)
  end

  get "/data.json" do
    json = File.read!(Path.join([__DIR__, "templates", "data.json"]))

    conn
    |> Plug.Conn.put_resp_content_type("application/json")
    |> send_resp(200, json)
  end

  post "/add_child" do
    data_path = Path.join([__DIR__, "templates", "data.json"])
    current_data = data_path |> File.read!() |> Jason.decode!()
    
    parent_id = conn.body_params["parentId"]
    child_name = conn.body_params["name"]
    
    new_id = (current_data["circles"] |> Enum.map(& &1["id"]) |> Enum.max()) + 1
    
    new_circle = %{
      "id" => new_id,
      "radius" => 50,
      "color" => "#3498db",
      "label" => child_name,
      "parentId" => parent_id
    }
    
    updated_data = Map.update!(current_data, "circles", &(&1 ++ [new_circle]))
    File.write!(data_path, Jason.encode!(updated_data))

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(updated_data))
  end

  post "/delete_circle" do
    data_path = Path.join([__DIR__, "templates", "data.json"])
    current_data = data_path |> File.read!() |> Jason.decode!()
    
    circle_id = conn.body_params["id"]
    
    # Remove the circle and its children from the data
    updated_circles = current_data["circles"] 
      |> Enum.reject(fn circle -> 
        circle["id"] == circle_id || circle["parentId"] == circle_id
      end)
    
    updated_data = Map.put(current_data, "circles", updated_circles)
    File.write!(data_path, Jason.encode!(updated_data))

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Jason.encode!(updated_data))
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end