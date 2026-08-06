# Non-starter column exposure, end to end (gsm.mapping#139)
# sdrgreas (SDRGCOMP) is the one newly exposed source column; compreas (STUDCOMP)
# predates this work but is now what confirms a non-starter. Routed through the
# real Ingest -> identity mapping -> NonStarter pipeline rather than hand-built
# frames, so the STUDCOMP spec, the mapping and complete_non_starter() are
# checked together. Reads the SOURCE workflow YAMLs via the load_all system.file
# shim (resolved here, in the package namespace).

test_that("a non-blank compreas confirms a non-starter through the real mapping pipeline (#139)", {
  wf_dir <- file.path(
    system.file(package = "gsm.mapping"),
    "workflow",
    "1_mappings"
  )
  wf <- workr::MakeWorkflowList(
    strNames = c("SUBJ", "SDRGCOMP", "STUDCOMP", "NonStarter"),
    strPath = wf_dir
  )

  # S1 confirms on compreas alone, S2 is dosed, S3 is never dosed but blank.
  lSourceData <- list(
    Raw_SUBJ = data.frame(
      studyid = "S",
      invid = "I1",
      country = "US",
      subjid = c("S1", "S2", "S3"),
      enrollyn = c("Y", "Y", "Y"),
      timeonstudy = c(100L, 100L, 100L),
      firstdosedate = as.Date(c(NA, "2020-02-01", NA)),
      mincreated_dts = as.POSIXct(rep("2020-01-01", 3)),
      stringsAsFactors = FALSE
    ),
    # No coded sdrgreas anywhere: confirmation has to come from compreas.
    Raw_SDRGCOMP = data.frame(
      studyid = "S",
      subjid = c("S1", "S2", "S3"),
      sdrgyn = c("Y", "N", "Y"),
      phase = c("1", "1", "1"),
      sdrgreas = c(
        "Study Drug Discontinued",
        "Study Drug Completed",
        "Study Drug Discontinued"
      ),
      mincreated_dts = as.POSIXct(rep("2020-01-01", 3)),
      stringsAsFactors = FALSE
    ),
    Raw_STUDCOMP = data.frame(
      studyid = "S",
      invid = "I1",
      subjid = c("S1", "S2", "S3"),
      compyn = c("Y", "N", "N"),
      compreas = c("Withdrew Consent", "", ""),
      mincreated_dts = as.POSIXct(rep("2020-01-01", 3)),
      stringsAsFactors = FALSE
    )
  )

  raw <- gsm.mapping::Ingest(lSourceData, gsm.mapping::CombineSpecs(wf))
  mapped <- workr::RunWorkflows(wf, raw)

  # The source columns survive the spec filter into the mapped domains.
  expect_true("sdrgreas" %in% names(mapped$Mapped_SDRGCOMP))
  expect_true("compreas" %in% names(mapped$Mapped_STUDCOMP))
  expect_type(mapped$Mapped_STUDCOMP$compreas, "character")

  # A blank must survive Ingest as a blank, not as NA - the confirmation test
  # guards on both, but only a real round trip can prove which one arrives.
  blank <- mapped$Mapped_STUDCOMP$compreas[
    mapped$Mapped_STUDCOMP$subjid == "S3"
  ]
  expect_false(is.na(blank))
  expect_equal(trimws(blank), "")

  status <- setNames(
    mapped$Mapped_NonStarter$nonstarter_status,
    mapped$Mapped_NonStarter$subjid
  )
  expect_equal(status[["S1"]], "Confirmed")
  expect_equal(status[["S2"]], "Started")
  expect_equal(status[["S3"]], "Potential-outside")
  expect_equal(sum(mapped$Mapped_NonStarter$confirmed_nonstarter), 1L)
})
