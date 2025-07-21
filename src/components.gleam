import gleam/int
import gleam/list
import gleam/result
import gleam/string
import gleam/time/calendar.{type Date, Date}
import lustre/attribute.{attribute}
import lustre/element.{element}
import lustre/element/svg
import lustre/event
import plinth/javascript/date
import types.{ClickedCalendarDay}

pub fn calendar() {
  element(
    "calendar-date",
    [
      attribute.id("cal"),
      attribute.class(
        "cally bg-base-100 border border-base-300 shadow-lg rounded-box",
      ),
      attribute("value", ""),
      attribute("locale", "ja-JP"),
      event.on_change(fn(event) { ClickedCalendarDay(event) }),
    ],
    [
      svg.svg(
        [
          attribute("viewBox", "0 0 24 24"),
          attribute("xmlns", "http://www.w3.org/2000/svg"),
          attribute("slot", "previous"),
          attribute.class("fill-current size-4"),
          attribute("aria-label", "Previous"),
        ],
        [
          svg.path([
            attribute("d", "M15.75 19.5 8.25 12l7.5-7.5"),
            attribute("fill", "currentColor"),
          ]),
        ],
      ),
      svg.svg(
        [
          attribute("viewBox", "0 0 24 24"),
          attribute("xmlns", "http://www.w3.org/2000/svg"),
          attribute("slot", "next"),
          attribute.class("fill-current size-4"),
          attribute("aria-label", "Next"),
        ],
        [
          svg.path([
            attribute("d", "m8.25 4.5 7.5 7.5-7.5 7.5"),
            attribute("fill", "currentColor"),
          ]),
        ],
      ),
      element("calendar-month", [], []),
    ],
  )
}

pub fn parse_date_string(date: String) -> Result(Date, Nil) {
  let splited = string.split(date, "-")

  case splited {
    [year, month, day] -> {
      use year <- result.try(int.parse(year))
      use day <- result.try(int.parse(day))
      use month <- result.try(int.parse(month))
      use month <- result.try(calendar.month_from_int(month))

      Ok(Date(year, month, day))
    }
    _ -> Error(Nil)
  }
}

pub fn today() -> String {
  let now = date.now()

  [date.year(now), date.month(now), date.day(now)]
  |> list.map(int.to_string)
  |> string.join("-")
}
