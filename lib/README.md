# Functions used in the analysis

## Overview
Here stores  useful functions to support the data processing and analysis steps, but do not constitute a statistical analysis per se.

## Scripts description
- **01-helpers-initial data process.R**: processing of raw data including warning days, daylight saving time, etc.
- **02-helpers-Insentec warning.R**: data cleaning of Insentec raw data
- **03-helpers-Insentec summary.R**: summary of feeding and drinking behaviours detected from the Insentec system
- **04-helpers-synchronicity matrix.R**: matrix documenting which cows are present, how much feed left in each bin, which bins are occupancy for every single second in 10 months
- **05-helpers-replacement.R**: detect replacement behaviours at the feeder
- **06-prep for dominance calculation.R**: data processing to get ready for dominance hierarchy calculation
- **07-25 level feeder occupancy dyad analysis.R**: changes in unknown dyads and two-way dyads as feeder occupancy increases
- **08-grouped dyadic analysis.R**:  changes in winning percentage in each dyad as feeder occupancy increases
- **globals.R**: global constant variables defined here
