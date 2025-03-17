# gsm.mapping 1.0.0

We are excited to announce the first major release of the `gsm.mapping` package, which contains essential mapping-specific functions and workflows for the GSM (Good Statistical Modeling) pipeline. This release introduces significant improvements, new features, and bug fixes, all aimed at improving the ease of use and functionality for users working with data mapping in the GSM pipeline.

## Notable Changes:
**Namespaces in Function Calls:**
We have standardized the function calls in workflows by adding namespaces to enhance modularity and avoid potential conflicts. This change helps improve readability and maintainability.
PR [#32](https://github.com/Gilead-BioStats/gsm.mapping/pulls/32) 

**New Mapping Workflows:**
A set of new workflows for handling gsm.endpoints and PK mapping have been added, streamlining the process of managing and utilizing endpoints within the pipeline.
PR [#31](https://github.com/Gilead-BioStats/gsm.mapping/pulls/31) 

**Replacing `clindata` with `gsm.datasim`:**
Replaced `clindata` with `gsm.datasim`, improving the data simulation workflow.
PR [#41](https://github.com/Gilead-BioStats/gsm.mapping/pulls/41) 

**`gsm.core` Update:**
The package has been updated to use gsm.core instead of the previously used gsm, ensuring compatibility with the new modular approach to the gsm pipeline.
PR [#46](https://github.com/Gilead-BioStats/gsm.mapping/pulls/46)

**Vignette Updates:**
Several improvements were made to the documentation and vignettes, providing users with clearer and more informative examples for using the mapping workflows, as well as .
PR [#44](https://github.com/Gilead-BioStats/gsm.mapping/pulls/44)

## Other Updates:
- Minor bug fixes and performance enhancements across various modules of the package.
- Improved error handling and logging for better debugging and workflow tracking.

For detailed information on the changes, please refer to the individual pull requests linked above.
 

# gsm.mapping 0.0.2

This initial release migrates the mapping-specific functions, workflows and documentation from `{gsm}` to `{gsm.mapping}`.
