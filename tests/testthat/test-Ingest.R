test_that("Ingest works with optional columns (#2)", {
  lSourceData <- list(
    df1 = data.frame(
      a = 1:10,
      b = letters[1:10]
    )
  )
  lSpec <- list(
    df1 = list(
      a = list(required = TRUE, type = "integer"),
      b = list(required = TRUE, type = "character"),
      c = list(required = FALSE, type = "character")
    )
  )
  expect_no_error(expect_message(expect_message({
    test_result <- Ingest(lSourceData, lSpec)
  })))
  expected_result <- list(
    Raw_df1 = lSourceData$df1
  )
  expect_identical(test_result, expected_result)
})

test_that("ApplySpec maps source columns and applies workr schema types (#131)", {
  dfSource <- data.frame(
    source_id = c("1", "2"),
    source_name = c("alpha", "beta"),
    optional = c("x", "y")
  )
  columnSpecs <- list(
    subject_id = list(source_col = "source_id", type = "integer"),
    subject_name = list(source_col = "source_name", type = "character"),
    missing_optional = list(source_col = "missing_optional", type = "character")
  )

  test_result <- ApplySpec(dfSource, columnSpecs, "df1")

  expected_result <- data.frame(
    subject_id = 1:2,
    subject_name = c("alpha", "beta")
  )
  expect_identical(test_result, expected_result)
})

test_that("ApplySpec supports dotted target column names", {
  dfSource <- data.frame(
    Title = c("Signal 1", "Signal 2"),
    State = c("Awaiting Triage", "Open Action")
  )
  columnSpecs <- list(
    "System.Title" = list(source_col = "Title", type = "character"),
    "System.State" = list(source_col = "State", type = "character")
  )

  test_result <- ApplySpec(dfSource, columnSpecs, "RiskSignalWorkItems")

  expected_result <- data.frame(
    "System.Title" = c("Signal 1", "Signal 2"),
    "System.State" = c("Awaiting Triage", "Open Action"),
    check.names = FALSE
  )
  expect_identical(test_result, expected_result)
})
