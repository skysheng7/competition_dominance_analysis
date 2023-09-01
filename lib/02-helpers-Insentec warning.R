
#' Generate empty dataframe prepared to hold Warning Data
#'
#' This function generates an empty data frame containing various warning/error
#' indicators related to cow feeding data.
#'
#' @param df_list A list of data frames containing feed, or water, or both feed and water data grouped by dates
#' @param data_source Insentec data source, can be "feed", "water" or "feed and water". To indicate is this just feed data, or just water data, or feed and water
#' @param time_zone Time zone to be used in date-time operations
#' 
#' @return An empty warning data frame.
generate_warning_df_empty <- function(df_list, data_source = "feed and water", time_zone) {
  
  # Ensure the input list is not empty
  if (length(df_list) == 0) {
    stop("The input list is empty!")
  }
  
  # Get date list
  date_list <- names(df_list)
  
  # Create the initial data frame
  Insentec_warning <- data.frame(date = ymd(date_list, tz = time_zone))
  
  # Adding additional columns with default values (blank)
  general_columns <- c(
    "total_cow_number", "missing_cow", "double_bin_detection_bin", 
    "double_cow_detection_bin", "negative_duration_bin", "negative_intake_bin",  
    "no_show_after_6pm_cows", "no_show_after_12pm_cows", "no_visit_after_6pm_bins",
    "no_visit_after_12pm_bins", "bins_not_visited_today", "bins_with_low_visits_today"
  )
  
  feed_columns <- c(
    "long_feed_duration_bin", "large_one_bout_feed_intake_bin", 
    "large_feed_intake_in_short_time_bin", "cows_no_visit_to_feed_bin", 
    "low_daily_feed_intake_cows", 
    "high_daily_feed_intake_cows", 
    "feed_add_time_no_found"
  )
  
  wat_columns <- c(
    "long_water_duration_bin", "large_one_bout_water_intake_bin", 
    "large_water_intake_in_short_time_bin", "cows_no_visit_to_water_bin", 
    "low_daily_water_intake_cows",
    "high_daily_water_intake_cows"
  )
  
  if (data_source == "feed and water") {
    warning_columns <- c(general_columns, feed_columns, wat_columns)
  } else if (data_source == "feed") {
    warning_columns <- c(general_columns, feed_columns)
  } else if (data_source == "water") {
    warning_columns <- c(general_columns, wat_columns)
  }
  
  
  # Add warning columns to the data frame
  for (col in warning_columns) {
    Insentec_warning[[col]] <- ""
  }
  
  return(Insentec_warning)
}


#' Compute Insentec warnings
#' 
#' This function processes the `all.comb` list to update the Insentec warning data frame.
#' It orders the data frame by date and computes the total number of unique cows.
#' 
#' @param df_list A list of data frames containing feed, or water, or both feed and water data grouped by dates
#' @param warning_df A data frame containing the Insentec warnings.
#' 
#' @return A modified Insentec warning data frame.
total_cow_num <- function(df_list, warning_df) {
  
  # Order by date
  warning_df <- warning_df[order(warning_df$date),]
  
  # Update total cow number based on unique cows
  for (i in 1:length(df_list)) {
    warning_df$total_cow_number[i] <- length(unique(df_list[[i]]$Cow))
  }
  
  return(warning_df)
}

#' Check long visit durations
#' 
#' This function inspects visit durations (for feeding or drinking) and checks for outliers. 
#' It also plots a boxplot of the master visit duration and updates the Insentec warning data frame 
#' with long visit durations.
#' 
#' @param all_data A list of data frames containing either feeding or drinking data.
#' @param high_duration A threshold for high durations. Default is 2000 seconds.
#' @param Insentec_warning A data frame containing the Insentec warnings.
#' @param type Character, either "feed" or "water".
#' 
#' @return A list containing rows with long visit durations for each data in all_data, and updated Insentec warning dataframe.
check_long_durations <- function(all_data, high_duration = 2000, 
                                 Insentec_warning, type = "feed") {
  
  require(here)  # Ensure the required package is loaded
  
  # create A data frame of master data (feeding or drinking).
  master_data <- merge_data(all_data)
  
  # Define the file name based on type
  plot_name <- ifelse(type == "feed", "feed_allDate_boxplot.pdf", "water_allDate_boxplot.pdf")
  pdfPath = here::here(paste0("graphs/", plot_name))
  
  pdf(file=pdfPath)
  boxplot(master_data$Duration, main=paste(names(all_data)[1], " to ", names(all_data)[length(all_data)], type, sep = "-"))
  dev.off() # close the pdf file
  
  long_duration_list <- list()
  for(u in 1:length(all_data)) {
    extended_data <- all_data[[u]][which(all_data[[u]]$Duration > high_duration),]
    cur_index <- length(long_duration_list)+1
    long_duration_list[[cur_index]] <- extended_data
    names(long_duration_list)[cur_index] <- names(all_data)[u]
    extended_bin <- sort(unique(extended_data$Bin))
    extended_bin_str <- paste(unlist(extended_bin), collapse="; ")
    colname_to_update <- ifelse(type == "feed", "long_feed_duration_bin", "long_water_duration_bin")
    Insentec_warning[u, colname_to_update] <- extended_bin_str #record it on warning message sheet
  }
  
  return(list("LongDurationList" = long_duration_list, "InsentecWarning" = Insentec_warning))
}


#' Detect and Return Double Detections for a Given Cow
#'
#' This function checks for overlapping visits for a given cow's data 
#' and returns rows where double detections occur.
#' 
#' @param dat2 A data frame containing data for a single cow.
#' 
#' @return A data frame containing rows where double detections occurred for the given cow.
get_double_detections_for_cow <- function(dat2) {
  detections <- data.frame()
  
  if(nrow(dat2) > 1) {
    for(k in 2:nrow(dat2)) {
      if(dat2[k, "Start"] < dat2[k-1, "End"]) {
        detections <- rbind(detections, dat2[(k-1):k, ])
      }
    }
  }
  
  return(detections)
}


#' Identify Double Detections for All Cows for a Given Day's Data
#'
#' This function goes through each cow's data for a specific day and identifies
#' cases of double detections (overlapping visits).
#' 
#' @param dat A data frame containing a single day's data for all cows.
#' 
#' @return A data frame containing all rows where double detections occurred for the given day.
get_double_detections_for_day <- function(dat) {
  daily_double_detection <- data.frame()
  cows <- unique(dat$Cow)
  
  for(cow in cows) {
    cow_data <- dat[dat$Cow == cow, ]
    cow_data <- cow_data[order(cow_data$Start), ]
    
    cow_double_detections <- get_double_detections_for_cow(cow_data)
    daily_double_detection <- rbind(daily_double_detection, cow_double_detections)
  }
  
  return(daily_double_detection)
}


#' Accumulate Double Detections for All Days
#'
#' This function iterates through all given days and checks for cases of 1 cow 2 
#' bin double detections: when the same cow was registered at 2 bins at the same 
#' time. It also updates a warning data frame with detected instances.
#' 
#' @param all_comb A list of data frames, each containing data for a specific day.
#' @param Insentec_warning A data frame where warnings regarding double detections are to be recorded.
#' 
#' @return A list containing two data frames: 
#'         - DoubleDetection: Consolidated double detections across all days
#'         - WarningData: Updated Insentec_warning data frame with recorded warnings.
get_all_double_detections_1cow2bin <- function(all_comb, Insentec_warning) {
  double_detection <- data.frame()
  double_bin_detection_list <- list()
  
  for(i in 1:length(all_comb)) {
    daily_double_detection <- get_double_detections_for_day(all_comb[[i]])
    
    double_detection <- rbind(double_detection, daily_double_detection)
    
    if(nrow(daily_double_detection) > 0) {
      faulty_bin <- daily_double_detection
      faulty_bin$rowNum <- seq_len(nrow(faulty_bin))
      faulty_bin2 <- faulty_bin[faulty_bin$rowNum %% 2 != 0, ]
      double_detection_bin <- sort(unique(faulty_bin2$Bin))
      Insentec_warning$double_bin_detection_bin[i] <- paste(double_detection_bin, collapse = "; ")
    }
    
    double_bin_detection_list[[i]] <- daily_double_detection
    names(double_bin_detection_list)[i] <- names(all_comb)[i]
  }
  
  return(list(DoubleDetectionList = double_bin_detection_list, WarningData = Insentec_warning))
}


#' Detect and Return Double Cow Detections for a Given Bin: The same bin regiesters 2 cows at the same time
#'
#' This function checks for overlapping visits by different cows for a given bin's data 
#' and returns rows where double detections of cows occur.
#' 
#' @param dat2 A data frame containing data for a single bin.
#' 
#' @return A data frame containing rows where double detections of cows occurred for the given bin.
get_double_cow_detection_for_bin <- function(dat2) {
  double_detection_rows <- data.frame() # empty data frame 
  
  if (nrow(dat2) > 1) {
    for(k in 2:nrow(dat2)) {
      if(dat2[k, "Start"] < dat2[k-1, "End"]) {
        double_detection_rows <- rbind(double_detection_rows, dat2[(k-1):k,])
      }
    }
  }
  
  return(double_detection_rows)
}

#' Identify Double Cow Detections for All Bins for a Given Day's Data
#'
#' This function goes through each bin's data for a specific day and identifies
#' cases of double cow detections (overlapping visits by different cows at the same bin).
#' 
#' @param dat A data frame containing a single day's data for all bins.
#' 
#' @return A data frame containing all rows where double detections of cows occurred for the given day.
get_double_cow_detections_for_day <- function(dat) {
  bins <- unique(dat$Bin)
  daily_double_cow_detection <- data.frame() 
  
  for(bin in bins) {
    bin_data = dat[dat$Bin == bin, ]
    bin_data = bin_data[order(bin_data$Start), ]
    double_detections = get_double_cow_detection_for_bin(bin_data)
    daily_double_cow_detection <- rbind(daily_double_cow_detection, double_detections)
  }
  
  return(daily_double_cow_detection)
}

#' Accumulate Double Cow Detections for All Days
#'
#' This function iterates through all given days and checks for cases of double 
#' cow detections: when the same bin registeres 2 cows at the same time
#' It also updates a warning data frame with detected instances.
#' 
#' @param all_comb A list of data frames, each containing data for a specific day.
#' @param Insentec_warning A data frame where warnings regarding double cow detections are to be recorded.
#' 
#' @return A list containing two data frames: 
#'         - DoubleCowDetection: Consolidated double cow detections across all days.
#'         - WarningData: Updated Insentec_warning data frame with recorded warnings.
get_all_double_cow_detections <- function(all_comb, Insentec_warning) {
  double_cow_detection <- data.frame()  
  double_cow_detection_list <- list()
  
  for(i in 1:length(all_comb)) {
    daily_data = get_double_cow_detections_for_day(all_comb[[i]])
    double_cow_detection <- rbind(double_cow_detection, daily_data)
    
    cur_index <- length(double_cow_detection_list) + 1
    double_cow_detection_list[[cur_index]] <- daily_data
    names(double_cow_detection_list)[cur_index] <- names(all_comb)[i]
    
    double_cow_detection_bin <- sort(unique(daily_data$Bin))
    Insentec_warning$double_cow_detection_bin[i] <- paste(unlist(double_cow_detection_bin), collapse="; ")
  }
  
  return(list("DoubleCowDetectionList" = double_cow_detection_list, "WarningData" = Insentec_warning))
}


#' Identify Negative Intakes and Durations
#'
#' @param data_list A list of data frames, either all_feed or all_water or both.
#' @param Insentec_warning A data frame where warnings regarding double cow detections are to be recorded.
#' @return A list containing negative duration list and negative intake list, insentec_warning dataframe.
record_negatives <- function(data_list, Insentec_warning) {
  
  negative_dur_list <- list()
  negative_intake_list <- list()
  
  for(i in 1:length(data_list)) {
    dat <- data_list[[i]]
    
    # Identify negative durations
    negative_duration <- dat[which(dat$Duration < 0),]
    negative_dur_list[[i]] <- negative_duration
    names(negative_dur_list)[i] <- names(data_list)[i]
    negative_duration_bin <- sort(unique(negative_duration$Bin))
    Insentec_warning$negative_duration_bin[i] <- paste(unlist(negative_duration_bin), collapse="; ")
    
    # Identify negative intakes (only those with more than 1 kg of negative intake)
    negative_intake <- dat[which(dat$Intake < 0),]
    negative_intake2 <- negative_intake[which(abs(negative_intake$Intake) > 1),]
    negative_intake_list[[i]] <- negative_intake2
    names(negative_intake_list)[i] <- names(data_list)[i]
    negative_intake_bin <- sort(unique(negative_intake2$Bin))
    Insentec_warning$negative_intake_bin[i] <- paste(unlist(negative_intake_bin), collapse="; ")
    
  }
  
  return(list(negative_duration = negative_dur_list, negative_intake = negative_intake_list, Insentec_warning = Insentec_warning))
}

#' Delete Negative Intakes and Durations
#'
#' @param data_list A list of data frames, either all_feed or all_water.
#' @return A list containing processed data
delete_negatives <- function(data_list) {
  for(i in 1:length(data_list)) {
    dat <- data_list[[i]]
    # delete negative duration and intake first
    dat <- dat[which(dat$Duration >= 0 & dat$Intake >= 0),]    
    
    # Set negative weights to zero and recalculate intake
    dat[which(dat$Startweight < 0), "Startweight"] <- 0
    dat[which(dat$Endweight < 0), "Endweight"] <- 0
    
    # Recalculate Intake after adjusting weights (assuming Intake = Startweight - Endweight)
    dat$Intake <- dat$Startweight - dat$Endweight
    
    # Delete negative intake again
    dat <- dat[which(dat$Intake >= 0),]
    
    # Calculate rate
    dat$rate <- dat$Intake/dat$Duration
    dat[is.infinite(dat$rate), "rate"] <- 0# Handle potential Inf values
    
    data_list[[i]] <- dat
  }
  
  return(data_list)
  
}

#' Identify Large Intakes In One Bout
#' 
#' @param data_list A list of data frames representing daily intakes (either feed or water).
#' @param Insentec_warning A data frame where warnings regarding double cow detections are to be recorded.
#' @param threshold The intake value that is considered as large.
#' @param source_d if this is for water data or feed data
#' 
#' @return A named list containing data frames for days with large intakes and insentec_warning data frame.
detect_large_intake <- function(data_list, threshold, Insentec_warning, source_d) {
  large_intake_list <- list()
  
  for(i in seq_along(data_list)) {
    dat <- data_list[[i]]
    large_intake <- dat[which(dat$Intake > threshold),]
    large_intake_list[[i]] <- large_intake
    names(large_intake_list)[i] <- names(data_list)[i]
    
    if (nrow(large_intake) > 0) {
      if (source_d == "feed") {
        Insentec_warning$large_one_bout_feed_intake_bin[i] <- paste(sort(unique(large_intake$Bin)), collapse = "; ")
      } else if (source_d == "water") {
        Insentec_warning$large_one_bout_water_intake_bin[i] <- paste(sort(unique(large_intake$Bin)), collapse = "; ")
      }
      
    }
  }
  
  return(list(
    large_intake = large_intake_list,
    Insentec_warning = Insentec_warning
  ))
}


#' Identify Large Intakes In Short Time
#' 
#' @param data_list A list of data frames representing daily intakes (either feed or water).
#' @param Insentec_warning A data frame where warnings regarding intake in a short time are recorded.
#' @param threshold_intake The intake value that is considered as large.
#' @param threshold_rate The rate value that is considered as rapid.
#' @param source_d if this is for water data or feed data
#' 
#' @return A named list containing data frames for days with large intakes in short time and insentec_warning data frame.
detect_large_intake_short_time <- function(data_list, threshold_intake, threshold_rate, Insentec_warning, source_d) {
  large_intake_short_time_list <- list()
  
  for(i in seq_along(data_list)) {
    dat <- data_list[[i]]
    short_time_intake <- dat[which(dat$Intake > threshold_intake & dat$rate > threshold_rate),]
    large_intake_short_time_list[[i]] <- short_time_intake
    names(large_intake_short_time_list)[i] <- names(data_list)[i]
    
    if (nrow(short_time_intake) > 0) {
      if (source_d == "feed") {
        Insentec_warning$large_feed_intake_in_short_time_bin[i] <- paste(sort(unique(short_time_intake$Bin)), collapse = "; ")
      } else if (source_d == "water") {
        Insentec_warning$large_water_intake_in_short_time_bin[i] <- paste(sort(unique(short_time_intake$Bin)), collapse = "; ")
      }
      
    }
  }
  
  return(list(
    large_intake_short_time = large_intake_short_time_list,
    Insentec_warning = Insentec_warning
  ))
}


#' Determine Last Seen Time
#'
#' @param df The data frame to process.
#' @param col The column name for which last seen times should be determined.
#' @return A data frame with the column of interest and the 'End' column.
determine_last_seen <- function(df, col) {
  df <- df[order(df[[col]], df$End), ]
  df$last_seen <- 0
  df$last_seen[nrow(df)] <- 1
  # go through every row to find the last time a cow/bin was seen 
  for (k in 1:(nrow(df)-1)) {
    if (df[k, col] != df[(k+1), col]){df$last_seen[k] <- 1}
  }
  
  last_seen_table <- df[df$last_seen == 1, c(col, "End")]
  return(last_seen_table)
}

#' Extract Warnings For Entities Not Seen After A Particular Time
#'
#' @param df The data frame to process.
#' @param col The column name.
#' @param time The cut-off time to check against.
#' @param time_zone Time zone to be used in date-time operations
#' @return A character string with the warnings.
extract_warnings <- function(df, col, time, time_zone) {
  df$End <- ymd_hms(df$End, tz = time_zone)
  not_seen_df <- df[df$End < time, ]
  not_seen_df$comb_string <- paste(not_seen_df[[col]], as.character(format(not_seen_df$End, "%H:%M:%S")), sep = ", ")
  warning_str <- paste(sort(unique(not_seen_df$comb_string)), collapse = "; ")
  return(warning_str)
}

#' Determine and Extract Cow No-Show Warnings
#'
#' This function iterates through a list of data frames and identifies 
#' situations where cows (and bins) did not appear after specific times of 
#' the day (6pm and 12pm). It returns a warning data frame with the extracted information.
#'
#' @param df_list A list of data frames, where each data frame represents 
#' observations for a specific date. Each data frame should contain columns 
#' related to the 'Cow' or 'Bin' and their respective timestamps.
#' @param Insentec_warning A data frame where warnings related to cow no-shows 
#' or bin visits are recorded. This data frame is updated during the function's 
#' execution and returned as the main output.
#' @param time_zone Time zone to be used in date-time operations
#' 
#' @return Insentec_warning
cows_no_show <- function(df_list, Insentec_warning, time_zone) {
  for (i in seq_along(df_list)) {
    after6pm <- ymd_hms(paste(names(df_list)[i], "17:59:59"), tz = time_zone)
    after12pm <- ymd_hms(paste(names(df_list)[i], "11:59:59"), tz = time_zone)
    
    # For Cows
    last_seen_cow <- determine_last_seen(df_list[[i]], "Cow")
    Insentec_warning$no_show_after_6pm_cows[i] <- extract_warnings(last_seen_cow, "Cow", after6pm, time_zone)
    Insentec_warning$no_show_after_12pm_cows[i] <- extract_warnings(last_seen_cow, "Cow", after12pm, time_zone)
    
    # For Bins
    last_seen_bin <- determine_last_seen(df_list[[i]], "Bin")
    Insentec_warning$no_visit_after_6pm_bins[i] <- extract_warnings(last_seen_bin, "Bin", after6pm, time_zone)
    Insentec_warning$no_visit_after_12pm_bins[i] <- extract_warnings(last_seen_bin, "Bin", after12pm, time_zone)
  }
  return(Insentec_warning)
}


#' Count the number of visits to each bin on a given day
#' 
#' @param data A dataframe representing the data of a specific day.
#' @param bin_list A dataframe of all bin numbers.
#' 
#' @return A dataframe with the number of visits to each bin on that day.
count_visits_per_bin <- function(data, bin_list) {
  visit_each_bin <- count(data, vars=c("Bin"))
  colnames(visit_each_bin) <- c("Bin", "Visit_freq")
  visit_each_bin2 <- merge(bin_list, visit_each_bin, all = TRUE)
  visit_each_bin2[is.na(visit_each_bin2)] <- 0
  
  return(visit_each_bin2)
}

#' Count the number of visits for each cow on each bin on a given day
#' 
#' @param data A dataframe representing the data of a specific day.
#' 
#' @return A dataframe with the number of visits for each cow on each bin.
count_visits_per_cow_bin <- function(data) {
  cow_bin_visit <- count(data, vars=c("Cow","Bin"))
  colnames(cow_bin_visit) <- c("Cow" ,"Bin", "Visit_freq")
  
  return(cow_bin_visit)
}

#' Determine the number of bins a cow visited on a given day
#' 
#' @param data A dataframe with the number of visits for each cow on each bin.
#' 
#' @return A dataframe detailing the number of feed and water bins each cow visited.
number_of_bins_per_cow <- function(data, bin_id_add) {
  cow_bin_visit_fed <- data[which(data$Bin < bin_id_add),]
  cow_bin_visit_wat <- data[which(data$Bin > bin_id_add),]
  num_bin_per_cow_fed <- count(cow_bin_visit_fed, vars=c("Cow"))
  colnames(num_bin_per_cow_fed) <- c("Cow", "num_of_feed_bins_visited")
  num_bin_per_cow_wat <- count(cow_bin_visit_wat, vars=c("Cow"))
  colnames(num_bin_per_cow_wat) <- c("Cow", "num_of_water_bins_visited")
  num_bin_per_cow_comb <- merge(num_bin_per_cow_fed, num_bin_per_cow_wat, all = TRUE)
  num_bin_per_cow_comb[is.na(num_bin_per_cow_comb)] <- 0
  num_bin_per_cow_comb$total_num_of_bins_visit <- num_bin_per_cow_comb$num_of_feed_bins_visited + num_bin_per_cow_comb$num_of_water_bins_visited
  
  return(num_bin_per_cow_comb)
}


#' Calculate Visits to Feed and Water Bins
#'
#' This function computes the number of visits to feed and water bins.
#' It also provides warnings for any irregularities such as bins not visited, 
#' or cows that didn't visit certain bins.
#'
#' @param df_list A list of data frames water bin or feed bin data or both water and feed bin data, grouped by date
#' @param min_feed_bin The smallest ID number for feed bins.
#' @param max_feed_bin The largest ID number for feed bins.
#' @param min_wat_bin The smallest ID number for water bins.
#' @param max_wat_bin The largest ID number for water bins.
#' @param bin_id_add The amount to add to water bin IDs to distinguish them from feed bin IDs.
#' @param total_cow_expt The expected total number of cows in the group
#' @param low_visit_threshold The threshold below which the number of visits to a bin is considered low.
#' @param Insentec_warning A data frame or list for storing warnings and irregularities.
#'
#' @return Returns the `Insentec_warning` data frame or list with added warnings and irregularities detected during the analysis.
bin_visit_count <- function(df_list, min_feed_bin, max_feed_bin, min_wat_bin, max_wat_bin, bin_id_add, total_cow_expt, low_visit_threshold, Insentec_warning) {
  # create a table with all the bin numbers
  feed_bin <- seq(min_feed_bin, max_feed_bin, by = 1)
  wat_bin <- seq((min_wat_bin + bin_id_add), (max_wat_bin + bin_id_add), by = 1)
  total_bin <- append(feed_bin, wat_bin)
  bin_list <- data.frame(total_bin)
  colnames(bin_list) <- c("Bin")
  
  bins_visit_num <- list()
  visit_per_bin_per_cow <- list()
  bin_num_visit_per_cow <- list()
  
  
  for (i in 1:length(df_list)) {
    # number of visits to each bin on each day
    bins_visit_num[[i]] <- count_visits_per_bin(df_list[[i]], bin_list)
    names(bins_visit_num)[i] <- names(df_list)[i]
    
    # number of visits for each cow on each bin on each day
    visit_per_bin_per_cow[[i]] <- count_visits_per_cow_bin(df_list[[i]])
    names(visit_per_bin_per_cow)[i] <- names(df_list)[i]
    
    # number of feed & water bins a cow visited each day
    num_bin_per_cow_comb <- number_of_bins_per_cow(visit_per_bin_per_cow[[i]], bin_id_add)
    bin_num_visit_per_cow[[i]] <- num_bin_per_cow_comb
    names(bin_num_visit_per_cow)[i] <- names(df_list)[i]
    
    # Cows that did not visit water bin / feed bin
    # Missing cow, cow ont showing up neither at water nor feed bin
    if (nrow(num_bin_per_cow_comb) < total_cow_expt) {
      Insentec_warning$missing_cow[i] <- "Yes"
    }
    # cows that no show at feed bin
    fed_no_show <- num_bin_per_cow_comb[which(num_bin_per_cow_comb$num_of_feed_bins_visited == 0),]
    fed_no_show_cow <- sort(unique(fed_no_show$Cow))
    Insentec_warning$cows_no_visit_to_feed_bin[i] <- paste(unlist(fed_no_show_cow), collapse="; ")
    # cows that no show at water bin
    wat_no_show <- num_bin_per_cow_comb[which(num_bin_per_cow_comb$num_of_water_bins_visited == 0),]
    wat_no_show_cow <- sort(unique(wat_no_show$Cow))
    Insentec_warning$cows_no_visit_to_water_bin[i] <- paste(unlist(wat_no_show_cow), collapse="; ")
    
    # bins not visited on each day
    no_visit <- bins_visit_num[[i]][which(bins_visit_num[[i]]$Visit_freq == 0),]
    no_visit_bin <- sort(unique(no_visit$Bin))
    Insentec_warning$bins_not_visited_today[i] <- paste(unlist(no_visit_bin), collapse="; ")
    
    # feed and water bins with low visits on each day
    visit_each_bin3 <- bins_visit_num[[i]]
    low_visit <- visit_each_bin3[which(visit_each_bin3$Visit_freq < low_visit_threshold),]
    low_visit_bin <- sort(unique(low_visit$Bin))
    Insentec_warning$bins_with_low_visits_today[i] <- paste(unlist(low_visit_bin), collapse="; ")
  }
  
  save(bins_visit_num, file = (here::here(paste0("data/results/", "Bins_with_number_of_visits_daily.rda"))))
  save(visit_per_bin_per_cow, file = (here::here(paste0("data/results/", "number_of_visits_for_each_bin_for_each_cow.rda"))))
  save(bin_num_visit_per_cow, file = (here::here(paste0("data/results/", "number_of_bins_visited_by_each_cow.rda"))))
  
  
  return(Insentec_warning)
}







generate_warning_df <- function(data_source = "feed and water", all_feed = NULL, 
                                all_water = NULL, high_feed_dur_threshold, 
                                high_water_dur_threshold, min_feed_bin, max_feed_bin, 
                                min_wat_bin, max_wat_bin, bin_id_add, 
                                total_cow_expt, low_visit_threshold, time_zone) {
  # create a list of data frames containing feed, or water, or both feed and water data grouped by dates
  if ((!is.null(all_feed)) & (!is.null(all_water))) {
    df_list <- combine_feeder_and_water_data(all_feed, all_water)
  } else if (!is.null(all_feed)) {
    df_list <- all_feed
  } else if (!is.null(all_water)) {
    df_list <- all_water
  } else {
    cat("No feed and water data was passed into the function! Please add feed data or water data or both.\n")
  }
  
  Insentec_warning <- generate_warning_df_empty(df_list, data_source, time_zone)
  long_feed_dur_list <- list()
  long_wat_dur_list <- list()
  
  ##### general Insentec warning: 
  # calculate total number of cows in the dataframe
  Insentec_warning <- total_cow_num(df_list, Insentec_warning)
  # double detection: same cow shows up at 2 bins
  results <- get_all_double_detections_1cow2bin(df_list, Insentec_warning)
  double_bin_detection_list <- results$DoubleDetectionList
  Insentec_warning <- results$WarningData
  save(double_bin_detection_list, file = (here::here(paste0("data/results/", "double_detection_1cow_2bins.rda"))))
  # double cow detection: same bin registers 2 cows
  results <- get_all_double_cow_detections(df_list, Insentec_warning)
  double_cow_detection_list <- results$DoubleCowDetectionList
  Insentec_warning <- results$WarningData
  save(double_cow_detection_list, file = (here::here(paste0("data/results/", "double_detection_1bin_2cows.rda"))))
  # record negative duration and intake
  all_results <- record_negatives(df_list, Insentec_warning)
  negative_dur_list <- all_results$negative_duration
  negative_intake_list <- all_results$negative_intake
  Insentec_warning <- all_results$Insentec_warning
  save(negative_dur_list, file = (here::here(paste0("data/results/", "negative_dur_list.rda"))))
  save(negative_intake_list, file = (here::here(paste0("data/results/", "negative_intake_list.rda"))))
  # record cows that did not visit any bins after 6 pm and 12 pm, and bins not 
  # visited by any cow after 6 pm and 12 pm
  Insentec_warning <- cows_no_show(df_list, Insentec_warning, time_zone)
  # record the total number of visits to each bin by each cow everyday
  Insentec_warning <-  bin_visit_count(df_list, min_feed_bin, max_feed_bin, min_wat_bin, max_wat_bin, bin_id_add, total_cow_expt, low_visit_threshold, Insentec_warning)
  
  
  ##### feed data warning
  if ((data_source == "feed") | (data_source == "feed and water")) {
    # long feeding duration 
    results <- check_long_durations(all_feed, high_feed_dur_threshold, Insentec_warning, type = "feed")
    long_feed_dur_list <- results$LongDurationList
    Insentec_warning <- results$InsentecWarning
    save(long_feed_dur_list, file = (here::here(paste0("data/results/", "long_feed_duration.rda"))))
    
    # delete negative duration and intake for feed
    all_feed <- delete_negatives(all_feed)
    # large feed intake in 1 bout
    results <- detect_large_intake(all_feed, large_feed_intake_bout_threshold, Insentec_warning, "feed") 
    large_feed_intake_in_one_bout <- results$large_intake
    Insentec_warning <- results$Insentec_warning
    save(large_feed_intake_in_one_bout, file = (here::here(paste0("data/results/", "large_feed_intake_in_one_bout.rda"))))
    
    # large feed intake in short time
    feed_results_short_time <- detect_large_intake_short_time(all_feed, large_feed_intake_short_time_threshold, 
                                                              large_feed_rate_short_time_threshold, 
                                                              Insentec_warning, "feed")
    large_feed_intake_in_short_time <- feed_results_short_time$large_intake_short_time
    Insentec_warning <- feed_results_short_time$Insentec_warning
    save(large_feed_intake_in_short_time, file = (here::here(paste0("data/results/", "large_feed_intake_in_short_time.rda"))))
    
    
  }
  
  ##### water data warning
  if ((data_source == "water") | (data_source == "feed and water")) {
    # long drinking duration 
    results <- check_long_durations(all_water, high_water_dur_threshold, Insentec_warning, type = "water")
    long_wat_dur_list <- results$LongDurationList
    Insentec_warning <- results$InsentecWarning
    save(long_wat_dur_list, file = (here::here(paste0("data/results/", "long_water_duration.rda"))))
    
    # delete negative duration and intake for water
    all_water <- delete_negatives(all_water)
    # large water intake in 1 bout
    results <- detect_large_intake(all_water, large_water_intake_bout_threshold, Insentec_warning, "water") 
    large_water_intake_in_one_bout <- results$large_intake
    Insentec_warning <- results$Insentec_warning
    save(large_water_intake_in_one_bout, file = (here::here(paste0("data/results/", "large_water_intake_in_one_bout.rda"))))
    
    # large water intake in short time
    wat_results_short_time <- detect_large_intake_short_time(all_water, large_water_intake_short_time_threshold, 
                                                             large_water_rate_short_time_threshold,
                                                             Insentec_warning, "water")
    large_water_intake_in_short_time <- wat_results_short_time$large_intake_short_time
    Insentec_warning <- wat_results_short_time$Insentec_warning
    save(large_water_intake_in_short_time, file = (here::here(paste0("data/results/", "large_water_intake_in_short_time.rda"))))
    
  }
  
  return(list(Insentec_warning, all_feed, all_water))

}


