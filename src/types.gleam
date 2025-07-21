pub type Model {
  Model(select_date: String)
}

pub type Msg {
  CalendarClicked
  ClickedCalendarDay(String)
}
