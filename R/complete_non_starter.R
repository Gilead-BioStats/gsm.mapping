#' Classify IP non-starter status per enrolled subject
#'
#' Joins the mapped subject, study-drug-completion and study-completion frames
#' to classify each enrolled subject's IP non-starter status. `Mapped_SUBJ` is
#' already filtered to `enrollyn == 'Y'`, so every row is an enrolled subject.
#'
#' A subject is a **confirmed** non-starter when they are enrolled, not dosed
#' (`firstdosedate` is `NA`) and have either a present study-completion
#' collection-end date (`colendat`) or the coded study-drug-completion reason
#' (`sdrgreas == chrNeverDosedReason`).
#'
#' @param dfSubjects `Mapped_SUBJ`: `studyid, subjid, invid, country,
#'   firstdosedate, timeonstudy`.
#' @param dfStudyDrugCompletion `Mapped_SDRGCOMP`: `studyid, subjid, sdrgreas`.
#' @param dfStudyCompletion `Mapped_STUDCOMP`: `studyid, subjid, colendat`.
#' @param nWindowDays `integer` window in days separating the two potential
#'   statuses; default `30`.
#' @param chrNeverDosedReason `character` coded `sdrgreas` value marking a
#'   confirmed non-starter; default `"Subject Never Dosed with Study Drug"`.
#'
#' @return a `data.frame` with one row per enrolled subject and columns
#'   `studyid, subjid, invid, country, dosed, nonstarter_status,
#'   confirmed_nonstarter`.
#' @export
#'
#' @examples
#' \dontrun{
#' lMapping <- workr::MakeWorkflowList(
#'   strPath = "workflow/1_mappings",
#'   strNames = c("SUBJ", "SDRGCOMP", "STUDCOMP"),
#'   strPackage = "gsm.mapping"
#' )
#' lRaw <- gsm.mapping::Ingest(lSource, gsm.mapping::CombineSpecs(lMapping))
#' mapped <- workr::RunWorkflows(lMapping, lRaw)
#' complete_non_starter(
#'   dfSubjects = mapped$Mapped_SUBJ,
#'   dfStudyDrugCompletion = mapped$Mapped_SDRGCOMP,
#'   dfStudyCompletion = mapped$Mapped_STUDCOMP
#' )
#' }
complete_non_starter <- function(
  dfSubjects,
  dfStudyDrugCompletion,
  dfStudyCompletion,
  nWindowDays = 30,
  chrNeverDosedReason = "Subject Never Dosed with Study Drug"
) {
  dfSubjects %>%
    dplyr::left_join(dfStudyDrugCompletion, by = c("studyid", "subjid")) %>%
    dplyr::left_join(dfStudyCompletion, by = c("studyid", "subjid")) %>%
    dplyr::mutate(
      dosed = !is.na(.data$firstdosedate),
      confirmed = !.data$dosed &
        (!is.na(.data$colendat) |
          (!is.na(.data$sdrgreas) & .data$sdrgreas == chrNeverDosedReason)),
      nonstarter_status = dplyr::case_when(
        .data$dosed ~ "Started",
        .data$confirmed ~ "Confirmed",
        .data$timeonstudy <= nWindowDays ~ "Potential-within",
        TRUE ~ "Potential-outside"
      ),
      confirmed_nonstarter = as.integer(.data$confirmed)
    ) %>%
    dplyr::select(
      "studyid",
      "subjid",
      "invid",
      "country",
      "dosed",
      "nonstarter_status",
      "confirmed_nonstarter"
    )
}
