#### 3.1 - Create a KRI Report using 12 standard metrics in a step-by-step workflow
library(gsm.core)
library(gsm.mapping)
library(dplyr)

core_mappings <- c("AE", "COUNTRY", "DATACHG", "DATAENT", "ENROLL", "LB",
                   "PD", "QUERY", "STUDY", "STUDCOMP", "SDRGCOMP", "SITE", "SUBJ")

lSource <- gsm.core::lSource
# Step 1 - Create Mapped Data Layer - filter, aggregate and join raw data to create mapped data layer
mappings_wf <- MakeWorkflowList(strNames = core_mappings, strPath = "workflow/1_mappings", strPackage = "gsm.mapping")
mappings_spec <- CombineSpecs(mappings_wf)
lRaw <- Ingest(lSource, mappings_spec)
mapped <- RunWorkflows(mappings_wf, lRaw)
