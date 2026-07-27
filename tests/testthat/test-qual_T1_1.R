# VS.yaml (#128)
test_that("Qual: VS.yaml mapping loads with expected format, independent of other domains (#128)", {
  vs_yaml <- read_yaml(
    file.path(
      system.file(package = "gsm.mapping"),
      "workflow",
      "1_mappings",
      "VS.yaml"
    )
  )

  # Meta block
  expect_equal(vs_yaml$meta$Type, "Mapped")
  expect_equal(vs_yaml$meta$ID, "VS")
  expect_true(is.character(vs_yaml$meta$Description))
  expect_true(is.numeric(vs_yaml$meta$Priority))

  # Spec is keyed off a single raw input, Raw_VS
  expect_equal(names(vs_yaml$spec), "Raw_VS")

  expected_fields <- c(
    "studyid",
    "subjid",
    "visit",
    "vs_dt",
    "vsperf_std",
    "weight",
    "height",
    "bmi",
    "sysbp",
    "diabp",
    "pulse",
    "temp",
    "resp",
    "bsa"
  )
  expected_types <- list(
    studyid = "character",
    subjid = "character",
    visit = "character",
    vs_dt = "Date",
    vsperf_std = "character",
    weight = "numeric",
    height = "numeric",
    bmi = "numeric",
    sysbp = "numeric",
    diabp = "numeric",
    pulse = "numeric",
    temp = "numeric",
    resp = "numeric",
    bsa = "numeric"
  )

  vs_spec <- vs_yaml$spec$Raw_VS
  expect_true(all(expected_fields %in% names(vs_spec)))

  iwalk(
    expected_types,
    ~ expect_equal(vs_spec[[.y]]$type, .x)
  )

  # Steps: single, direct (identity) mapping step producing Mapped_VS
  expect_length(vs_yaml$steps, 1)
  expect_equal(vs_yaml$steps[[1]]$output, "Mapped_VS")
  expect_equal(vs_yaml$steps[[1]]$name, "=")
  expect_equal(vs_yaml$steps[[1]]$params$lhs, "Mapped_VS")
  expect_equal(vs_yaml$steps[[1]]$params$rhs, "Raw_VS")
})

# Priority 1 mappings
test_that("Qual: mappings now done by individual domain, test that inputs and outputs of priority 1 mappings are completed as expected (#97, #114)", {
  priority1 <- c(
    "AE.yaml",
    "ENROLL.yaml",
    "LB.yaml",
    "PD.yaml",
    "SDRGCOMP.yaml",
    "STUDCOMP.yaml",
    "SUBJ.yaml",
    "OverallResponse.yaml",
    "Randomization.yaml"
  )

  mapped_p1_yaml <- map(
    priority1,
    ~ read_yaml(
      file.path(
        system.file(package = "gsm.mapping"),
        "workflow",
        "1_mappings",
        .x
      )
    )
  )

  # Required raw data is in data source
  iwalk(mapped_p1_yaml, ~ expect_true(all(names(.x$spec) %in% names(lData))))

  # Output from yaml is in the mapped data object
  iwalk(
    mapped_p1_yaml,
    ~ expect_true(flatten(.x$steps)$output %in% names(mapped_data))
  )

  # Needed columns of raw data are actually in raw data and retained in final data
  iwalk(
    mapped_p1_yaml,
    ~ expect_true(all(
      names(flatten(.x$spec)) %in% names(lData[names(.x$spec)][[1]])
    ))
  )
  iwalk(
    mapped_p1_yaml,
    ~ expect_true(all(
      names(flatten(.x$spec)) %in%
        names(mapped_data[[flatten(.x$steps)$output]])
    ))
  )
})


# Priority 2 Mappings

test_that("Qual: mappings now done by individual domain, test that inputs and outputs of priority 2 mappings are completed as expected (#97, #114)", {
  priority2 <- c("DATACHG.yaml", "DATAENT.yaml", "QUERY.yaml", "Death.yaml")

  mapped_p2_yaml <- map(
    priority2,
    ~ read_yaml(
      file.path(
        system.file(package = "gsm.mapping"),
        "workflow",
        "1_mappings",
        .x
      )
    )
  )

  iwalk(
    mapped_p2_yaml,
    ~ expect_true(all(names(.x$spec) %in% c(names(lData), "Mapped_SUBJ", "Mapped_Randomization", "Mapped_OverallResponse", "Mapped_STUDCOMP")))
  )

  iwalk(
    mapped_p2_yaml,
    ~ expect_true(
      flatten(.x$steps)$output %in% c(names(mapped_data), "Temp_SubjectLookup", "Temp_Death")
    )
  )

  iwalk(
    mapped_p2_yaml,
    ~ expect_true(all(
      names(flatten(.x$spec)) %in%
        c(
          names(lData[names(.x$spec)][[1]]), names(lData["Raw_SUBJ"][[1]]), names(lData["Raw_Randomization"][[1]]),
          names(lData["Raw_OverallResponse"][[1]]), names(lData["Raw_STUDCOMP"][[1]])
        )
    ))
  )
})

# Priority 3 Mappings

test_that("Qual: mappings now done by individual domain, test that inputs and outputs of priority 3 mappings are completed as expected (#97)", {
  priority3 <- c("COUNTRY.yaml", "SITE.yaml", "STUDY.yaml")

  mapped_p3_yaml <- map(
    priority3,
    ~ read_yaml(
      file.path(
        system.file(package = "gsm.mapping"),
        "workflow",
        "1_mappings",
        .x
      )
    )
  )

  iwalk(
    mapped_p3_yaml,
    ~ expect_true(all(names(.x$spec) %in% c(names(lData), "Mapped_SUBJ")))
  )

  temp_objs <- c(
    "Temp_CountryCountsWide",
    "Temp_CTMSSiteWide",
    "Temp_CTMSSite",
    "Temp_SiteCountsWide",
    "Temp_SiteCounts",
    "Temp_CTMSStudyWide",
    "Temp_CTMSStudy",
    "Temp_StudyCountsWide",
    "Temp_StudyCounts"
  )

  iwalk(
    mapped_p3_yaml,
    ~ expect_true(
      flatten(.x$steps)$output %in% c(names(mapped_data), temp_objs)
    )
  )

  iwalk(
    mapped_p3_yaml,
    ~ expect_true(all(
      names(flatten(.x$spec)) %in%
        c(names(lData[names(.x$spec)][[1]]), names(lData["Raw_SUBJ"][[1]]))
    ))
  )
})
