import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/json
import gleam/result
import mist
import todos

@external(erlang, "os", "getenv")
fn getenv(name: String) -> String

pub fn main() {
  let handler = fn(req: Request(mist.Connection)) -> Response(mist.ResponseData) {
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

  // Read PORT from the environment, parse it as an Int, default to 3000
  let port =
    getenv("PORT")
    |> int.parse
    |> result.unwrap(3000)

  let assert Ok(_) =
    handler
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(port)
    |> mist.start

  process.sleep_forever()
}
