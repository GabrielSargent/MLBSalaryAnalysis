
# STOR-664-MLBSalaryAnalysis-Group 2

## Team Members
- Mark Cahill (markbaconcahill)
- Jack McPherson (jackrymc)
- Gabriel Sargent (GabrielSargent)
- Hanieh Jamshidian (hanijamshidian)

## Overview
This repository contains the group project for STOR 664, Fall 2025.
Our goal is to build a linear regression model to predict MLB player salaries using key hitting statistics such as batting average, home runs, and RBIs. We test whether each statistic has a significant effect on salary (H₀: βᵢ = 0) and compare their relative importance (H₀: βᵢ > βⱼ) using partial R² values. If time allows, we will repeat the analysis for individual teams to see how these relationships differ across teams.

We use Sean Lahman’s Baseball Database, combining the salaries, batting, pitching, and master datasets through playerID. Our analysis covers 1985–2015, and we exclude pitchers because their hitting performance is not usually tied to their salary.

## Repository Structure
| Folder | Purpose | Key Files |
|---------|----------|-----------|
| `/data/raw` | Original unmodified datasets | `data1.csv`, `data2.csv` |
| `/data/processed` | Cleaned datasets ready for analysis | `merged_data.rds` |
| `/src` | Analysis and visualization code | `02_fit_models.R`, `03_generate_figures.R` |
| `/results/tables` | Numeric summaries | `model_performance.csv` |
| `/results/figures` | Visual outputs | `figure1.png` |
| `/report` | All written deliverables | `01_introduction.md`, `final_report.qmd` |

## Getting Started
### 1. Clone the repository

```bash
git clone <your .git url>
cd stor-664-project-sample
```

### 2. Install dependencies (optional but highly recommended)
Example in R:
```r
renv::restore()
```

Example in Python:
```python
pip install -r requirements.txt
```

### 3. Running Analysis Scripts
```r
Rscript scripts/03_generate_figures.R
```

---

## Contributing

1) Create a feature branch for each component of the project. For example, for the methods deliverable:
```bash
git checkout -b methods
```

2) Every team member should be working on this branch for the methods component of the project.
   - Use concise, meaningful messages:
     ```
     git commit -m "Add OLS model fitting script"
     ```
4) Before the submission deadline, open a PR and set Dr. Kessler and Shaleni as reviewers. If this is a peer reviwed component, make sure your reviewer(s) have access to the repository and are also assigned as reviewers on the PR. A link to your PR will need to be included as part of your Gradescope submission.
5) Incorporate feedback as necessary, update the feature branch, and close the PR before moving to the next component.
   - Your next feature branch should be created from your newly updated `main` branch.
   - `main` should only be updated from one of the feature branches after a PR.

## Peer Reviewing

For one component of the project you will be asked to peer-review another team's pull request. When doing so, make sure to leave **at least two** constructive comments. You will be asked to provide links to your two comments in Gradescope.

Your peer reviewers should be able to clone and run your repository to reproduce your results.

## Reports

Any medium can be used to generate the reports (MS Word, Latex, Quarto etc), however the final result will need to be a PDF file that will be placed in the `\reports` folder as well as uploaded on Gradescope.
