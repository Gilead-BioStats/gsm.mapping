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

lIngestWorkflow <- gsm.core::MakeWorkflowList(
  strName = core_mappings,
  strPath = "workflow/1_mappings", strPackage = "gsm.mapping"
)[[1]]
lRawData <- Ingest(lSourceData, lIngestWorkflow$spec)
#> ℹ Ingesting data for AE.
#> Creating a new temporary DuckDB connection.
#> ✔ SQL Query complete: 3000 rows returned.
#> Disconnected from temporary DuckDB connection.
```
