test_that("time_range owns endpoint and scalar canonical frequency checks", {
  day <- as.Date("2020-01-01")
  range <- time_range(day, day + 2, "A")
  expect_s3_class(range, "tosi_time_range")
  expect_identical(
    unclass(range),
    list(
      frequency = frequency_code("A"),
      first_period = day,
      last_period = day + 2
    )
  )
  expect_identical(time_range(day, day, frequency_code("M"))$last_period, day)
  expect_error(time_range(day + 1, day, "A"), "endpoints")
  expect_error(time_range(day, as.Date(NA), "A"), "endpoints")
  expect_error(time_range(c(day, day + 1), day + 2, "A"), "endpoints")
  expect_error(time_range(0, 1, "A"), "endpoints")
  expect_error(time_range(day, as.POSIXct(day), "A"), "endpoints")
  expect_error(time_range(day, day, c("A", "M")), "frequency")
  expect_error(time_range(day, day, NA_character_), "frequency")
  expect_error(time_range(day, day, "yearly"), "canonical")
})

test_that("as_time_range reduces Date and POSIXct without changing carriers", {
  days <- as.Date(c("2022-01-01", "2020-01-01", "2021-01-01"))
  expect_identical(as_time_range(days, "A"), time_range(days[2], days[1], "A"))
  times <- as.POSIXct(
    c("2020-02-01 12:00:00", "2020-02-01 09:00:00"),
    tz = "Europe/Helsinki"
  )
  range <- as_time_range(times, "H")
  expect_identical(range, time_range(times[2], times[1], "H"))
  expect_identical(attr(range$first_period, "tzone"), attr(times, "tzone"))
  expect_identical(attr(range$last_period, "tzone"), attr(times, "tzone"))
  expect_error(as_time_range(c(days, as.Date(NA)), "A"), "endpoints")
})
