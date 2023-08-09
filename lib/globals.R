###### Specify customized parameters related to data cleaning for this study ######

# List of cow IDs to be deleted because they are not actual cows
# Instead, they are test ear tags used during calibration
cow_delete_list <- c(0, 1556, 5015, 1111, 1112, 1113, 1114)

# Column names in the feed bin log files (change based on your own file format)
coln <- c("Transponder", "Cow", "Bin", "Start", "End", "Duration", "Startweight", "Endweight", "Comment", "Intake", "Intake2", "X1", "X2", "X3", "X4")

# Column names in the water bin log files
coln.wat <- c("Transponder", "Cow", "Bin", "Start", "End", "Duration", "Startweight", "Endweight", "Intake")

# List of feed transponder IDs to be deleted
feed_transponder_delete_list <- c(0)

# Min and Max values for feed bin
min_feed_bin <- 1
max_feed_Bin <- 30

# Columns to retain in the processed feed data
feed_coln_to_keep <- c("Transponder", "Cow", "Bin", "Start", "End", "Duration", "Startweight", "Endweight", "Intake")

# List of water transponder IDs to be deleted
wat_transponder_delete_list <- c(0)

# Min and Max values for water bin
min_wat_bin <- 1
max_wat_Bin <- 5

# Columns to retain in the processed water data
wat_coln_to_keep <- c("Transponder", "Cow", "Bin", "Start", "End", "Duration", "Startweight", "Endweight", "Intake")

# Additional value for bin ID, possibly used for specific calculations or mapping
bin_id_add <- 100

# Time zone to be used in date-time operations
time_zone <- "America/Los_Angeles"

# Insentec data source, is it just feed data, or just water data, or both.
data_source <- "both"  # can be "feed", or "water", or "both" means has both water and feed data

# duration threshold for what is coonsidered a long feeding visit  
high_feed_dur_threshold = 2000
