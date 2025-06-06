.le <- new.env(parent = emptyenv())

#' Parameters used in multiple functions
#'
#' @description Reused parameter definitions are gathered here for easier usage.
#'
#' @param dfMetrics `data.frame` Metric-specific metadata for use in charts and
#'   reporting. Created by passing an `lWorkflow` object to [gsm.reporting::MakeMetric()].
#'   Expected columns: `File`, `MetricID`, `Group`, `Abbreviation`, `Metric`,
#'   `Numerator`, `Denominator`, `Model`, `Score`, and `Threshold`. For more
#'   details see the Data Model vignette: `vignette("DataModel", package =
#'   "gsm.core")`.
#' @param dfResults `data.frame` A stacked summary of analysis pipeline output.
#'   Created by passing a list of results returned by [gsm.core::Summarize()] to
#'   [gsm.reporting::BindResults()]. Expected columns: `GroupID`, `GroupLevel`, `Numerator`,
#'   `Denominator`, `Metric`, `Score`, `Flag`, `MetricID`, `StudyID`,
#'   `SnapshotDate`.
#' @param dfBounds `data.frame` Set of predicted percentages/rates and upper-
#'   and lower-bounds across the full range of sample sizes/total exposure
#'   values for reporting. Created by passing `dfResults` and `dfMetrics` to
#'   [gsm.reporting::MakeBounds()]. Expected columns: `Threshold`, `Denominator`, `Numerator`,
#'   `Metric`, `MetricID`, `StudyID`, `SnapshotDate`.
#' @param dfGroups `data.frame` Group-level metadata dictionary. Created by
#'   passing CTMS site and study data to [MakeLongMeta()]. Expected columns:
#'   `GroupID`, `GroupLevel`, `Param`, `Value`.
#' @param dfInput `data.frame` Input data with one record per subject. Created
#'   by passing Raw+ data into [gsm.core::Input_Rate()]. Expected columns: `GroupID`,
#'   `GroupLevel`, `Numerator`, `Denominator` and/or columns specified in
#'   `strCountCol` and `strGroupCol`.
#' @param lMetric `list` Metric-specific metadata for use in charts and
#'   reporting. Created by passing an `lWorkflow` object to [gsm.reporting::MakeMetric()] and
#'   turing it into a list. Expected columns: `File`,`MetricID`, `Group`,
#'   `Abbreviation`, `Metric`, `Numerator`, `Denominator`, `Model`, `Score`, and
#'   `strThreshold`. For more details see the Data Model vignette:
#'   `vignette("DataModel", package = "gsm.core")`.
#' @param lParamLabels `list` Labels for parameters, with the parameters as
#'   names, and the label as value.
#' @param bDebug `logical` Print debug messages? Default: `FALSE`.
#'
#'
#' @name shared-params
#' @keywords internal
NULL
