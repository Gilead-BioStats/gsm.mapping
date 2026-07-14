# Ingests data from a source based on a given specification.

This function ingests data from a source based on a given specification.
It iterates over each domain in the specification and checks if the
columns exist in the source data. It then constructs a query to select
the columns from the source and calls the `RunQuery` function to
retrieve the data. The resulting data frames are stored in a list, where
each data frame corresponds to a domain in the specification.

## Usage

``` r
Ingest(lSourceData, lSpec, strDomain = "Raw")
```

## Arguments

- lSourceData:

  `list` A named list of source data frames.

- lSpec:

  `list` A named list of column specifications.

- strDomain:

  `character` Domain name to add to the data frames after ingestions.
  Default: "Raw"

## Value

`list` A named list of data frames, where each data frame corresponds to
a domain in the specification.

## Examples

``` r
core_mappings <- c(
  "AE", "COUNTRY", "DATACHG", "DATAENT", "ENROLL", "LB",
  "PD", "QUERY", "STUDY", "STUDCOMP", "SDRGCOMP", "SITE", "SUBJ"
)

lSourceData <- gsm.core::lSource

lIngestWorkflow <- workr::MakeWorkflowList(
  strNames = core_mappings,
  strPath = "workflow/1_mappings", strPackage = "gsm.mapping"
)[[1]]
lRawData <- Ingest(lSourceData, lIngestWorkflow$spec)
#> ℹ Ingesting data for AE.
#> [INFO] Creating a new temporary DuckDB connection.
#> duckdb is keeping downloaded extensions in a temporary directory:
#> ℹ /tmp/RtmpeTRcmH/duckdb/extensions
#> This is removed when the R session ends, so extensions are re-downloaded each session.
#> ℹ To keep them, point `options(duckdb.extension_directory =)` or the `DUCKDB_EXTENSION_DIRECTORY` environment variable at a permanent path.
#> [INFO] SQL Query complete: 3000 rows returned.
#> [INFO] Disconnected from temporary DuckDB connection.
```
