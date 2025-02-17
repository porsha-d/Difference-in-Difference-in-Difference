# Difference-in-Difference-in-Difference
 Difference-in-Difference-in-Difference analysis with cleaned dataset and Stata code.

Research Question: Do states with the CRC mandate have higher colorectal cancer screening?

Hypothesis: States with the CRC mandate will have higher CRC screening compared to those that do not have such a mandate. 



This repository contains the cleaned dataset and Stata code for a Difference-in-Difference-in-Difference (DDD) analysis.

## Files
- `code/todofileCRC_github.do`: The Stata do-file that performs the DDD analysis.

## How to Use
1. Download the dataset and the Stata do-file.
2. Please find the data file for the analysis in the following link:
[Google Drive File] (https://drive.google.com/file/d/1krTahn3sVnxN_xSntZ-FCifAD0xBzTUg/view?usp=sharing)
4. Open the do-file in Stata and set the correct file paths for the dataset.
5. Run the do-file to reproduce the analysis.

## Dataset Information

The dataset in this repository is based on the Behavioral Risk Factor Surveillance System (BRFSS) data provided by the Centers for Disease Control and Prevention (CDC).

Two Outcome variables:
-Last Blood Stool Test Within the Past Year
-Last Colonoscopy Within the Past Year

Statistical package used
-REGHDFE: Stata package that runs linear and instrumental-variable regressions with many levels of fixed effects

CRC screening= β0+ β1 CRC screening + β2 δs+ β3 λy+ β4X+ ε



### License
This dataset is licensed under the [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

### Citation
Behavioral Risk Factor Surveillance System (BRFSS), Centers for Disease Control and Prevention (CDC). Cleaned and prepared by [Porsha Dadgostar], [2022].

## Contact
For questions or feedback, please contact [github.com/porsha-d].
