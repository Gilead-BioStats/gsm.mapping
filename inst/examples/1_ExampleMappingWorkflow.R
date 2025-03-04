#### 3.1 - Create a KRI Report using 12 standard metrics in a step-by-step workflow
library(gsm)
library(gsm.mapping)
library(gsm.datasim)
library(dplyr)

core_mappings <- c("AE", "COUNTRY", "DATACHG", "DATAENT", "ENROLL", "LB",
                   "PD", "PK", "QUERY", "STUDY", "STUDCOMP", "SDRGCOMP", "SITE", "SUBJ")

basic_sim <- gsm.datasim::generate_rawdata_for_single_study(
  SnapshotCount = 1,
  SnapshotWidth = "months",
  ParticipantCount = 30,
  SiteCount = 5,
  StudyID = "ABC",
  workflow_path = "workflow/1_mappings",
  mappings = core_mappings,
  package = "gsm.mapping",
  desired_specs = NULL
)

lSource <- basic_sim[[1]]

lRaw <- list(
  Raw_SUBJ = lSource$Raw_SUBJ,
  Raw_AE = lSource$Raw_AE,
  Raw_PD = lSource$Raw_PD %>%
    rename(subjid = subjectenrollmentnumber),
  Raw_LB = lSource$Raw_LB,
  Raw_STUDCOMP = lSource$Raw_STUDCOMP %>%
    select(subjid, compyn),
  Raw_SDRGCOMP = lSource$Raw_SDRGCOMP,
  Raw_DATACHG = lSource$Raw_DATACHG %>%
    rename(subject_nsv = subjectname),
  Raw_DATAENT = lSource$Raw_DATAENT %>%
    rename(subject_nsv = subjectname),
  Raw_QUERY = lSource$Raw_QUERY %>%
    rename(subject_nsv = subjectname),
  Raw_ENROLL = lSource$Raw_ENROLL,
  Raw_SITE = lSource$Raw_SITE %>%
    rename(studyid = protocol) %>%
    rename(invid = pi_number) %>%
    rename(InvestigatorFirstName = pi_first_name) %>%
    rename(InvestigatorLastName = pi_last_name) %>%
    rename(City = city) %>%
    rename(State = state) %>%
    rename(Country = country) %>%
    rename(Status = site_status),
  Raw_STUDY = lSource$Raw_STUDY %>%
    rename(studyid = protocol_number) %>%
    rename(Status = status)
)


# Step 1 - Create Mapped Data Layer - filter, aggregate and join raw data to create mapped data layer
mappings_wf <- MakeWorkflowList(strName = core_mappings, strPath = "workflow/1_mappings", strPackage = "gsm.mapping")
mapped <- RunWorkflows(mappings_wf, lRaw)
