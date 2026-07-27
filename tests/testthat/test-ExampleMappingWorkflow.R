# Tests for the pkgdown "Example Mapping Workflow" example (#125).
#
# The example lives under pkgdown/, which is excluded from the built package via
# .Rbuildignore. These tests therefore only run from a source checkout (e.g. the
# qcthat run) and skip during R CMD check on the built tarball, where the file is
# absent.

examples_dir <- test_path("..", "..", "pkgdown", "menus", "examples")
rmd_path <- file.path(examples_dir, "Example_MappingWorkflow.Rmd")

test_that("Example Mapping Workflow is shipped as a rendered .Rmd, not a plain .R (#125)", {
  skip_if_not(
    dir.exists(examples_dir),
    "pkgdown example sources are not available in the built package"
  )

  # gsm.utils::build_assets() only renders .Rmd/.qmd sources into the pkgdown
  # examples menu, so the example must be an .Rmd.
  expect_true(file.exists(rmd_path))

  # The legacy plain-R example must be gone (it was never rendered in pkgdown).
  expect_false(
    file.exists(file.path(examples_dir, "1_ExampleMappingWorkflow.R"))
  )
})

test_that("Example Mapping Workflow has the front matter build_assets() relies on (#125)", {
  skip_if_not(file.exists(rmd_path), "pkgdown example not available")
  skip_if_not_installed("rmarkdown")

  fm <- rmarkdown::yaml_front_matter(rmd_path)

  # title + description populate the navbar menu entry.
  expect_true(is.character(fm$title) && nzchar(fm$title))
  expect_true(is.character(fm$description) && nzchar(fm$description))

  # index drives menu ordering and must be numeric.
  expect_false(is.null(fm$index))
  expect_false(is.na(suppressWarnings(as.numeric(fm$index))))

  # output is required for the file to render to HTML.
  expect_false(is.null(fm$output))
})

test_that("Example Mapping Workflow contains valid, complete Mapped Data Layer code (#125)", {
  skip_if_not(file.exists(rmd_path), "pkgdown example not available")
  skip_if_not_installed("knitr")

  # Extract the R code from the example's chunks.
  code_file <- tempfile(fileext = ".R")
  on.exit(unlink(code_file), add = TRUE)
  knitr::purl(rmd_path, output = code_file, quiet = TRUE)

  # The example code must be syntactically valid R.
  expect_error(parse(code_file), NA)

  code <- paste(readLines(code_file), collapse = "\n")

  # It must demonstrate the full Mapped Data Layer pipeline documented in #125.
  expect_match(code, "MakeWorkflowList")
  expect_match(code, "CombineSpecs")
  expect_match(code, "Ingest")
  expect_match(code, "RunWorkflows")
})
