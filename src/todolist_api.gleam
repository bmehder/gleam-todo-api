import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import mist.{type Connection, type ResponseData}
import todos

pub fn main() {
  let handler = fn(req: Request(Connection)) -> Response(ResponseData) {
    case request.path_segments(req) {
      ["todos"] -> {
        let json_body =
          todos.list_to_json(todos.all())
          |> json.to_string

        response.new(200)
        |> response.set_header("content-type", "application/json")
        |> response.set_header("Access-Control-Allow-Origin", "*")
        |> response.set_header("Access-Control-Allow-Headers", "*")
        |> response.set_body(mist.Bytes(bytes_tree.from_string(json_body)))
      }

      _ ->
        response.new(404)
        |> response.set_header("Access-Control-Allow-Origin", "*")
        |> response.set_header("Access-Control-Allow-Headers", "*")
        |> response.set_body(mist.Bytes(bytes_tree.from_string("Not found")))
    }
  }

  let assert Ok(_) =
    handler
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(3000)
    |> mist.start

  process.sleep_forever()
}
