# Mapping Specifications

## Mapping Workflows

Currently, there exist 19 domains that have respective workflows that
require mapping from source/raw data. 13 are general domains used across
several packages and extensions:

- AE
- DATACHG
- DATAENT
- ENROLL
- LB
- PD
- PK
- QUERY
- SDRGCOMP
- SITE
- STUDCOMP
- STUDY
- SUBJ

And 6 are domains that are currently specific to the `gsm.endpoints`
extension package:

- Baseline
- Consents
- Death
- OverallResponse
- Randomization
- Visit

Each of the above 20 domains generally map directly 1-to-1 from a raw
source, except `COUNTRY` which relies on the same dataset as `SUBJ`. The
following variables/types from their respective domains is **REQUIRED**
in the source/raw data:

#### Core Mappings

### Endpoint Mappings
