test_that("MakeBounds makes dfBounds", {
  gsm::reportingResults %>% dplyr::count(SnapshotDate)
  expect_snapshot({
    MakeBounds(
      dfResults = dplyr::filter(gsm::reportingResults, SnapshotDate == "2012-12-31"),
      dfMetrics = gsm::reportingMetrics
    )
  })
})

test_that("MakeBounds uses user-supplied strMetrics", {
  expect_snapshot({
    MakeBounds(
      dfResults = dplyr::filter(gsm::reportingResults, SnapshotDate == "2012-12-31"),
      dfMetrics = gsm::reportingMetrics,
      strMetrics = "Analysis_kri0001"
    )
  })
})

test_that("MakeBounds fails for NULLed arguments", {
  expect_error(
    {
      MakeBounds(
        dfResults = gsm::reportingResults,
        dfMetrics = gsm::reportingMetrics,
        strMetrics = NULL
      )
    },
    regexp = "strMetrics"
  )
  expect_error(
    {
      MakeBounds(
        dfResults = gsm::reportingResults,
        dfMetrics = gsm::reportingMetrics,
        dSnapshotDate = NULL
      )
    },
    regexp = "dSnapshotDate"
  )
  expect_error(
    {
      MakeBounds(
        dfResults = gsm::reportingResults,
        dfMetrics = gsm::reportingMetrics,
        strStudyID = NULL
      )
    },
    regexp = "strStudyID"
  )
})

test_that("MakeBounds fails gracefully for multiple arg values", {
  expect_warning(
    {
      expect_message(
        {
          dfBounds <- MakeBounds(
            dfResults = gsm::reportingResults,
            dfMetrics = gsm::reportingMetrics
          )
        },
        "Creating stacked dfBounds data"
      )
    },
    regexp = "SnapshotDate",
  )
  expect_null(dfBounds)
  expect_warning(
    {
      expect_message(
        {
          dfBounds <- MakeBounds(
            dfResults = dplyr::filter(gsm::reportingResults, SnapshotDate == "2012-12-31"),
            dfMetrics = gsm::reportingMetrics,
            strStudyID = c("a", "b")
          )
        },
        "Creating stacked dfBounds data"
      )
    },
    regexp = "StudyID",
  )
  expect_null(dfBounds)
})

test_that("MakeBounds makes poisson dfBounds", {
  reportingMetrics <- gsm::reportingMetrics
  reportingMetrics$Type <- "poisson"
  expect_snapshot({
    MakeBounds(
      dfResults = dplyr::filter(gsm::reportingResults, SnapshotDate == "2012-12-31"),
      dfMetrics = reportingMetrics
    )
  })
})
