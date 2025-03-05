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
# Step 1 - Create Mapped Data Layer - filter, aggregate and join raw data to create mapped data layer
mappings_wf <- MakeWorkflowList(strNames = core_mappings, strPath = "workflow/1_mappings", strPackage = "gsm.mapping")
mappings_spec <- CombineSpecs(mappings_wf)
lRaw <- Ingest(lSource, mappings_spec)
mapped <- RunWorkflows(mappings_wf, lRaw)
