import gleam/json
import gleam/list

pub type Todo {
  Todo(id: Int, description: String, completed: Bool, user_id: Int)
}

pub fn all() -> List(Todo) {
  [
    Todo(1, "Do something nice for someone I care about", False, 26),
    Todo(2, "Memorize a poem", True, 48),
    Todo(3, "Watch a classic movie", False, 4),
    Todo(4, "Watch a documentary", False, 14),
  ]
}

pub fn to_json(t: Todo) -> json.Json {
  json.object([
    #("id", json.int(t.id)),
    #("todo", json.string(t.description)),
    // <-- output matches dummyjson
    #("completed", json.bool(t.completed)),
    #("userId", json.int(t.user_id)),
  ])
}

pub fn list_to_json(todos: List(Todo)) -> json.Json {
  json.object([
    #("todos", json.array(todos, of: to_json)),
    #("total", json.int(list.length(todos))),
    #("skip", json.int(0)),
    #("limit", json.int(30)),
  ])
}
