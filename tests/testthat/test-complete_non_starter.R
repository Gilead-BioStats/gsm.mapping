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
    compreas = character(0),
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
  # C1 is confirmed by a recorded study-completion reason.
  dfStudyCompletion <- data.frame(
    studyid = "S",
    subjid = "C1",
    compreas = "Withdrew Consent",
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

test_that("complete_non_starter does not fan out on duplicate SDRGCOMP rows (#139)", {
  # Mapped_SDRGCOMP is a multi-record-per-subject domain in real data (per-phase
  # / snapshot rows; clindata::rawplus_sdrgcomp carries up to 2 rows per subject).
  # A confirmed non-starter with >1 SDRGCOMP row must still yield ONE output row
  # and contribute 1 to the numerator, not N.
  dfSubjects <- data.frame(
    studyid = "S",
    subjid = c("A", "B"),
    invid = c("I1", "I2"),
    country = c("US", "US"),
    firstdosedate = as.Date(c(NA, "2020-01-01")),
    timeonstudy = c(10L, 10L),
    stringsAsFactors = FALSE
  )
  # A appears twice in SDRGCOMP, both carrying the coded never-dosed reason.
  dfStudyDrugCompletion <- data.frame(
    studyid = "S",
    subjid = c("A", "A"),
    sdrgreas = c(NEVER_DOSED, NEVER_DOSED),
    stringsAsFactors = FALSE
  )
  out <- complete_non_starter(dfSubjects, dfStudyDrugCompletion, empty_stud())

  expect_equal(nrow(out), 2L)
  expect_equal(sum(out$subjid == "A"), 1L)
  expect_equal(out$nonstarter_status[out$subjid == "A"], "Confirmed")
  expect_equal(out$confirmed_nonstarter[out$subjid == "A"], 1L)
  # Numerator (sum of the 0/1 flag) must not exceed one per confirmed subject.
  expect_equal(sum(out$confirmed_nonstarter), 1L)
})

test_that("complete_non_starter does not fan out when duplicate SDRGCOMP rows disagree (#139)", {
  # Duplicate SDRGCOMP rows can disagree across snapshots; a subject is confirmed
  # by reason if ANY of their rows carries the coded never-dosed value, and still
  # collapses to a single output row.
  dfSubjects <- data.frame(
    studyid = "S",
    subjid = "A",
    invid = "I1",
    country = "US",
    firstdosedate = as.Date(NA),
    timeonstudy = 100L,
    stringsAsFactors = FALSE
  )
  dfStudyDrugCompletion <- data.frame(
    studyid = "S",
    subjid = c("A", "A"),
    sdrgreas = c("Study Drug Completed", NEVER_DOSED),
    stringsAsFactors = FALSE
  )
  out <- complete_non_starter(dfSubjects, dfStudyDrugCompletion, empty_stud())

  expect_equal(nrow(out), 1L)
  expect_equal(out$nonstarter_status, "Confirmed")
  expect_equal(out$confirmed_nonstarter, 1L)
})

test_that("complete_non_starter tolerates companion frames carrying invid/other columns (#139)", {
  # The real Mapped_SDRGCOMP / Mapped_STUDCOMP carry invid (and more) which must
  # not collide with Mapped_SUBJ's invid on the join.
  dfSubjects <- data.frame(
    studyid = "S",
    subjid = c("A", "B"),
    invid = c("I1", "I2"),
    country = c("US", "US"),
    firstdosedate = as.Date(c(NA, "2020-01-01")),
    timeonstudy = c(10L, 10L),
    stringsAsFactors = FALSE
  )
  dfStudyDrugCompletion <- data.frame(
    studyid = "S",
    subjid = "A",
    invid = "I1",
    sdrgyn = "Y",
    sdrgreas = NEVER_DOSED,
    stringsAsFactors = FALSE
  )
  dfStudyCompletion <- data.frame(
    studyid = "S",
    subjid = "A",
    invid = "I1",
    compyn = "Y",
    compreas = "Withdrew Consent",
    stringsAsFactors = FALSE
  )
  out <- complete_non_starter(
    dfSubjects,
    dfStudyDrugCompletion,
    dfStudyCompletion
  )
  expect_true("invid" %in% names(out))
  expect_equal(out$invid[out$subjid == "A"], "I1")
  expect_equal(out$nonstarter_status[out$subjid == "A"], "Confirmed")
  expect_equal(out$confirmed_nonstarter[out$subjid == "A"], 1L)
})

test_that("complete_non_starter does not confirm on a blank compreas (#139)", {
  # compreas is shared clinical data and is blank for most subjects, unlike the
  # private colendat marker it replaces - a blank must not confirm anyone.
  dfSubjects <- data.frame(
    studyid = "S",
    subjid = c("B1", "B2"),
    invid = "I1",
    country = "US",
    firstdosedate = as.Date(c(NA, NA)),
    timeonstudy = c(100L, 100L),
    stringsAsFactors = FALSE
  )
  dfStudyCompletion <- data.frame(
    studyid = "S",
    subjid = c("B1", "B2"),
    compreas = c("", "   "),
    stringsAsFactors = FALSE
  )
  out <- complete_non_starter(dfSubjects, empty_sdrg(), dfStudyCompletion)

  status <- setNames(out$nonstarter_status, out$subjid)
  expect_equal(status[["B1"]], "Potential-outside")
  expect_equal(status[["B2"]], "Potential-outside")
  expect_equal(sum(out$confirmed_nonstarter), 0L)
})

test_that("complete_non_starter matches the never-dosed reason case-insensitively (#139)", {
  # Source systems are not guaranteed to preserve the coded value's casing, and
  # an exact-match miss fails silently: the subject slides from Confirmed to
  # Potential-outside with no error raised.
  dfSubjects <- data.frame(
    studyid = "S",
    subjid = c("U1", "L1", "M1"),
    invid = "I1",
    country = "US",
    firstdosedate = as.Date(c(NA, NA, NA)),
    timeonstudy = c(100L, 100L, 100L),
    stringsAsFactors = FALSE
  )
  dfStudyDrugCompletion <- data.frame(
    studyid = "S",
    subjid = c("U1", "L1", "M1"),
    sdrgreas = c(
      "SUBJECT NEVER DOSED WITH STUDY DRUG",
      "subject never dosed with study drug",
      "Subject Never Dosed with Study Drug"
    ),
    stringsAsFactors = FALSE
  )
  out <- complete_non_starter(dfSubjects, dfStudyDrugCompletion, empty_stud())

  status <- setNames(out$nonstarter_status, out$subjid)
  expect_equal(status[["U1"]], "Confirmed")
  expect_equal(status[["L1"]], "Confirmed")
  expect_equal(status[["M1"]], "Confirmed")
  expect_equal(sum(out$confirmed_nonstarter), 3L)
})
