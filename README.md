[Imgur](https://i.imgur.com/nPFTyNz.gifv)

# Increased competition flattens the dominance hierarchy

This repository contains the data and code for our project: **Redefining dominance calculation: Increased competition flattens the dominance hierarchy in dairy cows**.

## Getting Started

To load this project, please follow the instructions below:

1. Set your working directory to the folder where this `README.md` file is located using `setwd()`.

2. Run the following R code to install required R packages:

```r
# List of packages to be installed
packages <- c("lubridate", "plyr", "here", "zoo", "ggplot2", "EloRating", "EloSteepness", "viridis", "dplyr", "lme4", "lmerTest")

# Function to check and install missing packages
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg, dependencies = TRUE)
  }
}

# Apply the function to each package
sapply(packages, install_if_missing)
```

4. Run the following R code to load this R project:

```r
library('ProjectTemplate')
load.project()
```
3. Repository Structure
Here's a brief overview of the repository's structure:

- **cache**: Contains crucial intermediate data used in the final analysis.
- **config**: Holds the configuration settings for this R project.
- **data**: Contains both the raw data and the processed data resulting from our analysis.
- **graphs**: Stores all the visual plots and graphs generated during the analysis.
- **lib**: Houses helper functions crafted to assist in analysis and preprocessing.
- **munge**: Contains scripts that utilize functions to preprocess the data.
- **renv**: Provides details about the R environment set up during the project's inception.
- **reports**: Contains the manuscript detailing our findings and observations.
- **src**: Contains scripts used for the final statistical analysis.

Thank you for your interest in our project. We hope you find the data and code insightful!

## Dataset Information

- **Title of Dataset:** Replication Data for: Increased competition flattens the dominance hierarchy: evidence from a herd living ungulate  
- **Dataset Created:** 2023-07-29  
- **Created by:** Kehan (Sky) Sheng

## Contributors

- **Principal Investigator:** Marina von Keyserlingk  
  - ORCID: 0000-0002-1427-3152  
  - Affiliation: University of British Columbia  
  - Email: <nina@mail.ubc.ca>

- **Co-Investigator:** Daniel Weary  
  - ORCID: 0000-0002-0917-3982  
  - Affiliation: University of British Columbia  
  - Email: <dan.weary@ubc.ca>

- **Contributor:** Kehan Sheng  
  - ORCID: 0000-0001-6442-5284  
  - Affiliation: University of British Columbia  
  - Email: <skysheng7@gmail.com>

- **Contributor:** Borbala Foris  
  - ORCID: 0000-0002-0901-3057  
  - Affiliation while working on this project: University of British Columbia
  - Current affiliation: University of Veterinary Medicine, Vienna
  - Email: <forisbori@gmail.com>

- **Contributor:** Joseph Krahn  
  - ORCID: 0000-0002-1559-1216  
  - Affiliation: University of British Columbia  
  - Email: <joey10krahn@gmail.com>

## Project Information

- **Date of Data Collection:** July 15, 2020 - May 19, 2021  
- **Location of Data Collection:** UBC Dairy Education and Research Centre, 6947 No. 7 Highway, Agassiz, BC V0M 1A0, Canada  
- **Funding:** This project was supported by the NSERC Industrial Research Chair.
