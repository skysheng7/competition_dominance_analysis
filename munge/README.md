# Data Preprocessing and Munging for Project

## Overview
This directory contains scripts for data preprocessing or data munging specific to this project.

## Scripts Execution Order
The scripts within the `munge` folder are not configured to execute automatically upon invoking `load.project()`. However, this behavior can be modified in the project configuration. The filenames contain numbers indicating the recommended sequence for running these scripts.

## Performance Warning
**Important Notice:**
- The scripts process a substantial volume of data spanning 10 months.
- They include complex computations, notably calculating feed amounts across 30 bins every second.
- Due to these factors, running the full suite of scripts is time-intensive.
- **Expected Runtime:** Approximately 12 hours.

Please plan your resource allocation and processing time accordingly.
