# Non-starter column exposure (gsm.mapping#139)
# sdrgreas (SDRGCOMP) and colendat (STUDCOMP) must flow through the identity
# mappings to Mapped_SDRGCOMP / Mapped_STUDCOMP. Ingest-routed so it exercises
# the production spec-filtering path, reading the SOURCE workflow YAMLs via the
# load_all system.file shim (resolved here, in the package namespace).

test_that("SDRGCOMP exposes sdrgreas and STUDCOMP exposes colendat through Ingest + RunWorkflows (#139)", {
  wf_dir <- file.path(
    system.file(package = "gsm.mapping"),
    "workflow",
    "1_mappings"
  )
  wf <- workr::MakeWorkflowList(
    strNames = c("SDRGCOMP", "STUDCOMP"),
    strPath = wf_dir
  )
  lSpec <- gsm.mapping::CombineSpecs(wf)

  lSourceData <- list(
    Raw_SDRGCOMP = data.frame(
      studyid = "S",
      subjid = c("S1", "S2"),
      sdrgyn = c("Y", "N"),
      phase = c("1", "1"),
      sdrgreas = c(
        "Subject Never Dosed with Study Drug",
        "Study Drug Completed"
      ),
      mincreated_dts = as.POSIXct(c("2020-01-01", "2020-01-02")),
      stringsAsFactors = FALSE
    ),
    Raw_STUDCOMP = data.frame(
      studyid = "S",
      invid = c("I1", "I1"),
      subjid = c("S1", "S2"),
      compyn = c("Y", "N"),
      compreas = c("", ""),
      colendat = as.Date(c("2020-02-01", NA)),
      mincreated_dts = as.POSIXct(c("2020-01-01", "2020-01-02")),
      stringsAsFactors = FALSE
    )
  )

  raw <- gsm.mapping::Ingest(lSourceData, lSpec)
  mapped <- workr::RunWorkflows(wf, raw)

  expect_true("sdrgreas" %in% names(mapped$Mapped_SDRGCOMP))
  expect_true("colendat" %in% names(mapped$Mapped_STUDCOMP))
  expect_s3_class(mapped$Mapped_STUDCOMP$colendat, "Date")
  expect_true(
    "Subject Never Dosed with Study Drug" %in% mapped$Mapped_SDRGCOMP$sdrgreas
  )
  expect_false(is.na(mapped$Mapped_STUDCOMP$colendat[
    mapped$Mapped_STUDCOMP$subjid == "S1"
  ]))
})
