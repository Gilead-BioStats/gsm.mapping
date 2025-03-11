<!-- badges: start -->

[![R-CMD-check](https://github.com/Gilead-BioStats/gsm.mapping/workflows/R-CMD-check-main/badge.svg)](https://github.com/Gilead-BioStats/gsm.mapping/actions) 

<!-- badges: end -->

# Good Statistical Monitoring Mapping {gsm.mapping} R package

The {gsm} ecosystem provides a standardized Risk Based Quality Monitoring (RBQM) framework for clinical trials that pairs a flexible data pipeline with robust reports like the one shown below.  

<center> 
 
![](man/figures/gsm_report_screenshot_1.png)

</center>

The `{gsm.mapping}` package provides the necessary functions and workflows to perform the data transformation from raw/source datasets to appropriate domains.
This README provides a high-level overview of {gsm.mapping}; see the [package website](https://gilead-biostats.github.io/gsm.mapping/) for additional details.


# Background 
Clinical trial data often presents challenges due to its complexity and variability. The gsm.mapping framework is designed to accommodate a wide range of clinical data sources. Typically, raw data from clinical trial databases is transformed into mapped datasets through straightforward transformations. These mapped datasets then serve as inputs for the analytical pipeline.

When integrating data from the Clinical Trial Management System (CTMS), it is often necessary to consolidate and transform data from various folders and sources into appropriate "domains." During the reporting process, while SDTM standards are commonly applied to ensure compliance, they may not always align with the specific requirements of RBQM. The goal of `{gsm.mapping}` is to provide a flexible framework for mapping data into domains tailored to support risk assessments during trial monitoring.

There is no single standardized format for raw or mapped data within `{gsm.mapping}`. The only requirement is that mapped data must be compatible with the analytics pipeline. Data transformations can be implemented using various methods, including custom R scripts (e.g., with dplyr), SQL queries, or pre-defined gsm workflows. Pre-defined workflows can be found in this package in the `workflow` directory, or as examples in the [gsm Extensions vignette](https://gilead-biostats.github.io/gsm.core/articles/gsmExtensions.html#mappings).

# Process Overview
The workflow for a particular mapped domain requires the following sections:
 - Metadata: Describes the domain and its mapping purpose.
 - spec: Defines the structure of the raw data inputs and their expected types.
 - steps: Outlines the process for transforming raw data into the mapped output.

