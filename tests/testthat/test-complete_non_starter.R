# Mapped_NonStarter derivation (gsm.mapping#139)
# Hand-built frames pin all four statuses and the WindowDays boundary, so these
# tests pass independently of the datasim test data / gsm.core::lSource regen.

NEVER_DOSED <- "Subject Never Dosed with Study Drug"

empty_sdrg <- function() {
  data.frame(
    studyid = character(0),
    subjid = character(0),
    sdrgreas = character(0),
    stringsAsFactors = FALSE
  )
}
empty_stud <- function() {
  data.frame(
    studyid = character(0),
    subjid = character(0),
    colendat = as.Date(character(0)),
    stringsAsFactors = FALSE
  )
}

test_that("complete_non_starter classifies all four statuses (#139)", {
  dfSubjects <- data.frame(
    studyid = "S",
    subjid = c("D1", "W1", "O1", "C1", "C2"),
    invid = c("I1", "I1", "I2", "I2", "I3"),
    country = c("US", "US", "DE", "DE", "FR"),
    firstdosedate = as.Date(c("2020-01-01", NA, NA, NA, NA)),
    timeonstudy = c(100L, 20L, 40L, 40L, 31L),
    stringsAsFactors = FALSE
  )
  # C2 is confirmed by the coded sdrgreas even though its window says "outside".
  dfStudyDrugCompletion <- data.frame(
    studyid = "S",
    subjid = "C2",
    sdrgreas = NEVER_DOSED,
    stringsAsFactors = FALSE
  )
  # C1 is confirmed by a present colendat.
  dfStudyCompletion <- data.frame(
    studyid = "S",
    subjid = "C1",
    colendat = as.Date("2020-02-01"),
    stringsAsFactors = FALSE
  )

  out <- complete_non_starter(
    dfSubjects,
    dfStudyDrugCompletion,
    dfStudyCompletion
  )

  status <- setNames(out$nonstarter_status, out$subjid)
  expect_equal(status[["D1"]], "Started")
  expect_equal(status[["W1"]], "Potential-within")
  expect_equal(status[["O1"]], "Potential-outside")
  expect_equal(status[["C1"]], "Confirmed")
  expect_equal(status[["C2"]], "Confirmed")

  conf <- setNames(out$confirmed_nonstarter, out$subjid)
  expect_equal(unname(conf[c("D1", "W1", "O1")]), c(0L, 0L, 0L))
  expect_equal(unname(conf[c("C1", "C2")]), c(1L, 1L))

  dosed <- setNames(out$dosed, out$subjid)
  expect_true(dosed[["D1"]])
  expect_false(any(dosed[c("W1", "O1", "C1", "C2")]))
})

test_that("complete_non_starter keeps one row per enrolled subject with the expected columns (#139)", {
  dfSubjects <- data.frame(
    studyid = "S",
    subjid = c("A", "B"),
    invid = "I1",
    country = "US",
    firstdosedate = as.Date(c(NA, "2020-01-01")),
    timeonstudy = c(10L, 10L),
    stringsAsFactors = FALSE
  )
  out <- complete_non_starter(dfSubjects, empty_sdrg(), empty_stud())
  expect_equal(nrow(out), 2L)
  expect_true(all(
    c(
      "studyid",
      "subjid",
      "invid",
      "country",
      "dosed",
      "nonstarter_status",
      "confirmed_nonstarter"
    ) %in%
      names(out)
  ))
  expect_type(out$confirmed_nonstarter, "integer")
})

test_that("complete_non_starter honours the WindowDays boundary: 30 within, 31 outside (#139)", {
  dfSubjects <- data.frame(
    studyid = "S",
    subjid = c("B30", "B31"),
    invid = "I",
    country = "US",
    firstdosedate = as.Date(c(NA, NA)),
    timeonstudy = c(30L, 31L),
    stringsAsFactors = FALSE
  )
  out <- complete_non_starter(dfSubjects, empty_sdrg(), empty_stud())
  status <- setNames(out$nonstarter_status, out$subjid)
  expect_equal(status[["B30"]], "Potential-within")
  expect_equal(status[["B31"]], "Potential-outside")
})

test_that("complete_non_starter respects a custom nWindowDays (#139)", {
  dfSubjects <- data.frame(
    studyid = "S",
    subjid = c("X", "Y"),
    invid = "I",
    country = "US",
    firstdosedate = as.Date(c(NA, NA)),
    timeonstudy = c(45L, 61L),
    stringsAsFactors = FALSE
  )
  out <- complete_non_starter(
    dfSubjects,
    empty_sdrg(),
    empty_stud(),
    nWindowDays = 60
  )
  status <- setNames(out$nonstarter_status, out$subjid)
  expect_equal(status[["X"]], "Potential-within")
  expect_equal(status[["Y"]], "Potential-outside")
})
