import components
import gleam/int
import lustre
import lustre/attribute.{class}
import lustre/effect.{type Effect}
import lustre/element.{text}
import lustre/element/html.{div, p}
import plinth/browser/window
import types.{type Model, type Msg, CalendarClicked, ClickedCalendarDay}

pub fn main() {
  let app = lustre.application(init, update, view)
  let assert Ok(_) = lustre.start(app, "#app", Nil)
  Nil
}

fn init(_flags) -> #(Model, Effect(Msg)) {
  #(types.Model(select_date: ""), effect.none())
}

fn update(_model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  case msg {
    ClickedCalendarDay(date) -> {
      #(
        types.Model(select_date: date),
        effect.from(fn(dispatch) {
          window.add_event_listener("change", fn(_event) {
            dispatch(CalendarClicked)
          })
        }),
      )
    }
    types.CalendarClicked -> #(types.Model(select_date: ""), effect.none())
  }
}

fn view(model: Model) -> element.Element(Msg) {
  let date = {
    case components.parse_date_string(model.select_date) {
      Ok(date) -> int.to_string(date.day)
      Error(_) -> ""
    }
  }
  div([class("flex items-center justify-center min-h-screen")], [
    div([class("flex flex-col items-center space-y-4")], [
      p([], [text("選択された日付: " <> date <> "日")]),
      components.calendar(),
    ]),
  ])
}
