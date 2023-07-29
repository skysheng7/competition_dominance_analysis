###################################################################################################
######################################### TO BE DELETED ###########################################
###################################################################################################

# Load all packages from library
library(lubridate)
library(plyr)
library(ggplot2)

daylight_saving_table <- read.csv(here("data/daylight_saving_csv.csv"), header = TRUE)
warning_days <- read.csv(here("data/warning_days.csv"), header = TRUE)


################################################################################
###################### data loading & processing ###############################
################################################################################
# set work directory and load data
input_dir <- here("data")
output_dir <- here("result")

# load in feed and water data
fileNames.f <- list.files(path = here("data/feed_test"),full.names = TRUE,
                          recursive = TRUE,pattern =".DAT")
fileNames.w <- list.files(path = here("data/water_test"),full.names = TRUE,
                          recursive = TRUE,pattern =".DAT")
fileNames.f <- sort(fileNames.f)
fileNames.w <- sort(fileNames.w)

################################################################################
############# customized processing for this study (hard-coded) ################
################################################################################
# this part involves processing the data that is customized for this study only
# please change this based on your study
# process daylight saving dates dataframe and warning date data frame
daylight_saving_table <- daylight_saving_process(daylight_saving_table)
warning_days$date <- ymd(warning_days$date, tz="America/Los_Angeles")







