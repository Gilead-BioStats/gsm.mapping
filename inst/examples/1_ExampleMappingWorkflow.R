#### 3.1 - Create a KRI Report using 12 standard metrics in a step-by-step workflow
library(gsm)
library(gsm.mapping)
library(dplyr)

# Source Data
lSource <- list(
    Source_SUBJ = clindata::rawplus_dm,
    Source_AE = clindata::rawplus_ae,
    Source_PD = clindata::ctms_protdev,
    Source_LB = clindata::rawplus_lb,
    Source_STUDCOMP = clindata::rawplus_studcomp,
    Source_SDRGCOMP = clindata::rawplus_sdrgcomp %>% dplyr::filter(.data$phase == 'Blinded Study Drug Completion'),
    Source_DATACHG = clindata::edc_data_points,
    Source_DATAENT = clindata::edc_data_pages,
    Source_QUERY = clindata::edc_queries,
    Source_ENROLL = clindata::rawplus_enroll,
    Source_SITE = clindata::ctms_site,
    Source_STUDY = clindata::ctms_study
)

# Step 0 - Data Ingestion - standardize tables/columns names
lRaw <- list(
    Raw_SUBJ = lSource$Source_SUBJ,
    Raw_AE = lSource$Source_AE,
    Raw_PD = lSource$Source_PD %>%
      rename(subjid = subjectenrollmentnumber),
    Raw_LB = lSource$Source_LB,
    Raw_STUDCOMP = lSource$Source_STUDCOMP,
    Raw_SDRGCOMP = lSource$Source_SDRGCOMP,
    Raw_DATACHG = lSource$Source_DATACHG %>%
      rename(subject_nsv = subjectname),
    Raw_DATAENT = lSource$Source_DATAENT %>%
      rename(subject_nsv = subjectname),
    Raw_QUERY = lSource$Source_QUERY %>%
      rename(subject_nsv = subjectname),
    Raw_ENROLL = lSource$Source_ENROLL,
    Raw_SITE = lSource$Source_SITE %>%
      rename(studyid = protocol) %>%
      rename(invid = pi_number) %>%
      rename(InvestigatorFirstName = pi_first_name) %>%
      rename(InvestigatorLastName = pi_last_name) %>%
      rename(City = city) %>%
      rename(State = state) %>%
      rename(Country = country),
    Raw_STUDY = lSource$Source_STUDY %>%
      rename(studyid = protocol_number) %>%
      rename(Status = status)
)

# Step 1 - Create Mapped Data Layer - filter, aggregate and join raw data to create mapped data layer
mappings_wf <- MakeWorkflowList(strPath = "workflow/1_mappings", strPackage = "gsm.mapping")
mapped <- RunWorkflows(mappings_wf, lRaw)
