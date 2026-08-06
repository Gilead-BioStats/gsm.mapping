#' Classify IP non-starter status per enrolled subject
#'
#' Joins the mapped subject, study-drug-completion and study-completion frames
#' to classify each enrolled subject's IP non-starter status. `Mapped_SUBJ` is
#' already filtered to `enrollyn == 'Y'`, so every row is an enrolled subject.
#'
#' A subject is a **confirmed** non-starter when they are enrolled, not dosed
#' (`firstdosedate` is `NA` or blank) and have either a non-blank study-completion reason
#' (`compreas`) or the coded study-drug-completion reason (`sdrgreas` matching
#' `chrNeverDosedReason`, compared case-insensitively).
#'
#' `nonstarter_status` is assigned by explicit predicate: `"Started"` when
#' dosed, `"Confirmed"` when a confirmed non-starter, `"Potential-within"` /
#' `"Potential-outside"` for the remaining subjects whose `timeonstudy` falls at
#' or below vs. above `nWindowDays`, and `NA` when none apply (e.g. `timeonstudy`
#' is missing so the window cannot be evaluated).
#'
#' @param dfSubjects `Mapped_SUBJ`: `studyid, subjid, invid, country,
#'   firstdosedate, timeonstudy`.
#' @param dfStudyDrugCompletion `Mapped_SDRGCOMP`: `studyid, subjid, sdrgreas`.
#' @param dfStudyCompletion `Mapped_STUDCOMP`: `studyid, subjid, compreas`.
#' @param nWindowDays `integer` window in days separating the two potential
#'   statuses; default `30`.
#' @param chrNeverDosedReason `character` coded `sdrgreas` value marking a
#'   confirmed non-starter, matched ignoring case; default
#'   `"Subject Never Dosed with Study Drug"`.
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
  # Collapse each companion frame to one row per (studyid, subjid) before
  # joining. Mapped_SDRGCOMP/STUDCOMP are multi-record-per-subject domains in
  # real data (per-phase / snapshot rows; clindata::rawplus_sdrgcomp carries up
  # to two rows per subject), so a bare left_join would fan out Mapped_SUBJ and
  # over-count the confirmed-non-starter numerator downstream. Reducing to a
  # per-subject flag (confirmed by reason if ANY row carries the coded value)
  # also drops the invid/other columns that would otherwise collide on the join.
  sdrg_by_subject <- dfStudyDrugCompletion %>%
    dplyr::group_by(.data$studyid, .data$subjid) %>%
    dplyr::summarise(
      never_dosed_reason = any(
        !is.na(.data$sdrgreas) &
          toupper(.data$sdrgreas) == toupper(chrNeverDosedReason)
      ),
      .groups = "drop"
    )
  stud_by_subject <- dfStudyCompletion %>%
    dplyr::group_by(.data$studyid, .data$subjid) %>%
    dplyr::summarise(
      has_compreas = any(
        !is.na(.data$compreas) & trimws(.data$compreas) != ""
      ),
      .groups = "drop"
    )

  dfSubjects %>%
    dplyr::left_join(sdrg_by_subject, by = c("studyid", "subjid")) %>%
    dplyr::left_join(stud_by_subject, by = c("studyid", "subjid")) %>%
    dplyr::mutate(
      dosed = !is.na(.data$firstdosedate) & trimws(.data$firstdosedate) != "",
      confirmed = !.data$dosed &
        (dplyr::coalesce(.data$has_compreas, FALSE) |
          dplyr::coalesce(.data$never_dosed_reason, FALSE)),
      nonstarter_status = dplyr::case_when(
        .data$dosed ~ "Started",
        .data$confirmed ~ "Confirmed",
        .data$timeonstudy <= nWindowDays ~ "Potential-within",
        .data$timeonstudy > nWindowDays ~ "Potential-outside",
        TRUE ~ NA_character_
      ),
      confirmed_nonstarter = as.integer(.data$confirmed)
    ) %>%
    dplyr::select(
      dplyr::all_of(
        c(
          "studyid",
          "subjid",
          "invid",
          "country",
          "dosed",
          "nonstarter_status",
          "confirmed_nonstarter"
        )
      )
    )
}
