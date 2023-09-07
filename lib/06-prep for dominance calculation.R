################################################################################
############## Enrolled & Excluded cow presence tracking #######################
################################################################################

#' Track Cow Enrollment and Exclusion Over Time
#'
#' This function records the number of cows in a group over different days, 
#' and logs which cows got excluded or enrolled.
#'
#' @param all_comb A list of data frames where each data frame corresponds to a day's cow records.
#' @param time_zone A string indicating the time zone, default is "America/Los_Angeles".
#'
#' @return A data frame that contains daily statistics about cow enrollment and exclusion.
#' 
#' @import lubridate
#' @export
cow_track <- function(all_comb, time_zone = "America/Los_Angeles") {
  date_list <- ymd(names(all_comb), tz=time_zone)
  cow_track_sheet <- data.frame(date_list)
  colnames(cow_track_sheet) <- c("date")
  cow_track_sheet$cow_num <- 0
  cow_track_sheet$cow_list <- ""
  cow_track_sheet$excluded_num <- 0
  cow_track_sheet$excluded_cow <- ""
  cow_track_sheet$enroll_num <- 0
  cow_track_sheet$enroll_cow <- ""
  cow_track_sheet$re_enrolled <- ""
  
  for (date_i in 1:length(date_list)) {
    cur_sheet <- all_comb[[date_i]]
    cur_cow_list <- sort(unique(cur_sheet$Cow))
    cur_cow_num <- length(cur_cow_list)
    cow_track_sheet$cow_num[date_i] <- cur_cow_num
    cow_track_sheet$cow_list[date_i] <- paste(unlist(cur_cow_list), collapse="; ")
    
    # if this is the first day of the trial
    if (date_i == 1) {
      total_cow_list <- cur_cow_list
      
      # if this is not the first day of the trial 
    } else {
      
      prev_cow_list <- as.integer(strsplit(cow_track_sheet$cow_list[date_i - 1], "; ")[[1]])
      enrolled <- setdiff(cur_cow_list, prev_cow_list)
      excluded <- setdiff(prev_cow_list, cur_cow_list)
      
      # record cows newly enrolled
      if (length(enrolled) != 0) {
        cow_track_sheet$enroll_num[date_i] <- length(enrolled)
        cow_track_sheet$enroll_cow[date_i] <- paste(unlist(enrolled), collapse="; ")
        reEnrolled <- intersect(total_cow_list, enrolled) # the total cow list did not included cows from today yet
        
        # check if they had experience in the group before (they were in the group before, 
        # excluded in the past, but now they were re-enrolled)
        if (length(reEnrolled) != 0) {
          cow_track_sheet$re_enrolled[date_i] <- paste(unlist(reEnrolled), collapse="; ")
        }
        
      }
      
      # record cows excluded
      if (length(excluded) != 0) {
        cow_track_sheet$excluded_num[date_i] <- length(excluded)
        cow_track_sheet$excluded_cow[date_i] <- paste(unlist(excluded), collapse="; ")
      }
      
      # update the total cow list in the end 
      total_cow_list <- unique(c(total_cow_list, cur_cow_list))
    }
  }
  
  return(cow_track_sheet)
}

#' Identify Regrouping Days
#'
#' This function identifies days where there was regrouping (enrollment and exclusion of cows).
#' It also applies filters to discard days based on certain criteria such as technical issues.
#'
#' @param all.comb2 A list of data frames containing daily cow data.
#' @param warning_days A data frame containing dates and their respective warnings.
#'
#' @return A data frame showing days when there was regrouping.
identify_regoup <- function(all.comb2, warning_days) {
  # identify days that need to be discarded
  days_to_be_discarded <- warning_days[which(warning_days$Red_warning != ""),]
  days_to_be_discarded$date <- ymd(days_to_be_discarded$date,tz = time_zone)
  
  # track cow enroll and exclude data
  cow_track_sheet <- cow_track(all.comb2)
  cow_track_sheet <- merge(cow_track_sheet, days_to_be_discarded, all = TRUE) # delete days that has technical issues
  cow_track_sheet <- cow_track_sheet[which(!is.na(cow_track_sheet$cow_num)),]
  cow_track_sheet2 <- cow_track_sheet[which((cow_track_sheet$enroll_num != 0) | (cow_track_sheet$excluded_num != 0)),]
  cow_track_sheet3 <- cow_track_sheet2[-which((!is.na(cow_track_sheet2$Red_warning)) & ((cow_track_sheet2$excluded_num > 12) | (cow_track_sheet2$enroll_num > 12))),]
  # mark down regrouping days
  regrouping <- cow_track_sheet3[which(cow_track_sheet3$enroll_num > 2),]
  
  save(regrouping, file = here::here(paste0("data/results/", "regrouping.rda")))
  
  return(regrouping)
}
################################################################################
######################### Data processing functions ############################
################################################################################

#' Extra Processing for Master Feed Sheet
#'
#' This function provides additional processing for a master feed data frame. 
#' It extracts specific columns and adds new ones like 'date', 'start_hour', and 'end_hour'.
#'
#' @param master_sheet A data frame containing the master feed and water data.
#'
#' @return A data frame that has been processed to include only desired columns and some new ones.
feed_extra_processing <- function(master_sheet) {
  master_sheet <- master_sheet[, c("Cow", "Bin", "Start", "End", "date")]
  master_sheet$start_hour <- hour(master_sheet$Start)
  master_sheet$end_hour <- hour(master_sheet$End)
  return(master_sheet)
}


#' Check and Create Directory
#'
#' Checks if a specific directory exists, and if not, creates it.
#'
#' @param output_dir A character string specifying the directory path to check and potentially create.
#'
#' @return None. The function will create the directory if it doesn't exist.
dir_check_create <- function(output_dir){
  if (!dir.exists(output_dir)) {
    dir.create(output_dir)
  }
}



#' Process Feed Replacement Data
#'
#' This function modifies and computes new variables in the `master_feed_replacement_all`
#' data frame based on various input data frames/lists. It calculates metrics related
#' to the number of bins occupied, number of bins with feed, etc. and most importantly 
#' calculates resource_occupancy which can also be refered to as feeder occupancy
#'
#' @param master_feed_replacement_all A data frame of feed replacements.
#' @param cows_present_each_second_list A list of data frames for cows present each second, indexed by date.
#' @param bins_occupied_for_feed_list A list of data frames of bins occupied for feeding, indexed by date.
#' @param feed_each_bin_list A list of data frames detailing feed amounts in each bin, indexed by date.
#' @param method_type Character string indicating the method type to be used in `pick_method`.
#' 
#' @return processed master_feed_replacement_all 
replace_processing <- function(master_feed_replacement_all, cows_present_each_second_list, bins_occupied_for_feed_list, feed_each_bin_list, method_type) {
  master_feed_replacement_all$unoccupied_bin_with_feed <- -1
  master_feed_replacement_all$unoccupied_empty_bin <- -1
  master_feed_replacement_all$occupied_total_bin <- -1
  master_feed_replacement_all$resource_occupancy <- -1
  master_feed_replacement_all$total_bin_with_feed <- -1
  master_feed_replacement_all$occupied_bin_with_feed <- -1
  
  for (y in 1:nrow(master_feed_replacement_all)) {
    cur_date <- as.character(master_feed_replacement_all$date[y])
    cur_time <- master_feed_replacement_all$Time[y]
    cur_bin <- master_feed_replacement_all$Bin[y]
    total_bin_num <- master_feed_replacement_all$total_bin[y]
    cur_cows_present_st <- cows_present_each_second_list[[cur_date]]
    cur_bin_occupied_st <- bins_occupied_for_feed_list[[cur_date]]
    cur_feed_each_bin_st <- feed_each_bin_list[[cur_date]]
    # calculate how many bins are not occupied right now
    available_bin_num <- cur_cows_present_st[which(cur_cows_present_st$Time == cur_time), "empty_bin_num"]
    
    # how many bins are occupied in total = number of cows present
    master_feed_replacement_all$occupied_total_bin[y] <- cur_cows_present_st[which(cur_cows_present_st$Time == cur_time), "total_bin_occupied"]
    
    # claculate total number of bins that has feed in them
    master_feed_replacement_all$total_bin_with_feed[y] <- total_bin_with_feed(cur_feed_each_bin_st, cur_time)
    
    # calculate the total number of occupied bins that has feed in them
    master_feed_replacement_all$occupied_bin_with_feed[y] <- occupied_bin_with_feed(cur_bin_occupied_st, cur_feed_each_bin_st, cur_time)
    
    # if all bins are occupied
    if (available_bin_num == 0) {
      # then mark the unoccupied_bin_with_feed as 0
      master_feed_replacement_all$unoccupied_bin_with_feed[y] <- 0
      master_feed_replacement_all$unoccupied_empty_bin[y] <- 0
      # if not all bins are occupied
    } else {
      # get a list of bins occupied
      cur_row_bin_occupied <- cur_bin_occupied_st[which(cur_bin_occupied_st$Time == cur_time), c(2:(ncol(cur_bin_occupied_st)-1))]
      bins_occupied_list <- unlist(cur_row_bin_occupied[1,], use.names = FALSE)
      bins_occupied_list2 <- sort(as.character(unique(bins_occupied_list[which(bins_occupied_list>0)])))
      
      # see how many of the bins available has feed > 0.5
      feed_in_bins <- cur_feed_each_bin_st[which(cur_feed_each_bin_st$Time == cur_time), ]
      feed_in_unoccupied_bins <- feed_in_bins[, -which(names(feed_in_bins) %in% bins_occupied_list2)]
      available_bin_with_feed_list <- unlist(feed_in_unoccupied_bins[1, c(2:(ncol(feed_in_unoccupied_bins)-2))], use.names = FALSE)
      unoccupied_bin_with_feed <- length(available_bin_with_feed_list[which(available_bin_with_feed_list>0.5)])
      unoccupied_empty_bin <- length(available_bin_with_feed_list[which(available_bin_with_feed_list<=0.5)])
      master_feed_replacement_all$unoccupied_bin_with_feed[y] <- unoccupied_bin_with_feed
      master_feed_replacement_all$unoccupied_empty_bin[y] <- unoccupied_empty_bin
    }
    
  }
  
  # preparing datasheet about replacement events
  master_feed_replacement_all$hour <- hour(master_feed_replacement_all$Time)
  
  # calculate Feeder Occupancy based on the method type picked in this script
  master_feed_replacement_all <- pick_method(master_feed_replacement_all, method_type)
  
  # average Feeder Occupancy by hour of the day
  master_feed_replacement_all <- ro_by_hour(master_feed_replacement_all)
  
  master_feed_replacement_all$resource_occupancy <- round(master_feed_replacement_all$resource_occupancy, digits = 5)
  
  return(master_feed_replacement_all)
}

#' Average Feeder Occupancy By Hour
#'
#' This function computes the average and standard deviation of the 'Feeder Occupancy'
#' (represented as `resource_occupancy` in the data) for each hour and then merges
#' the computed values back to the original data frame.
#'
#' @param master_feed_replacement_all A data frame of feed replacements with a `resource_occupancy` column.
#'
#' @return A modified version of `master_feed_replacement_all` with added columns for the average and standard deviation of `resource_occupancy` by hour.
ro_by_hour <- function(master_feed_replacement_all) {
  # get the average Feeder Occupancy  under each hour
  ro_by_hour_mean <- aggregate(master_feed_replacement_all$resource_occupancy, by = list(master_feed_replacement_all$hour), FUN = mean)
  colnames(ro_by_hour_mean) <- c("hour", "average_ro_10mon")
  ro_by_hour_sd <- aggregate(master_feed_replacement_all$resource_occupancy, by = list(master_feed_replacement_all$hour), FUN = sd)
  colnames(ro_by_hour_sd) <- c("hour", "SD_of_ro_10mon")
  master_feed_replacement_all <- merge(master_feed_replacement_all, ro_by_hour_mean)
  master_feed_replacement_all <- merge(master_feed_replacement_all, ro_by_hour_sd)
  
  return(master_feed_replacement_all)
}

#' Calculate Total Number of Bins with More Than 0.5kg Feed
#'
#' This function returns the number of bins that contain more than 0.5 units of feed 
#' at a specified time from a provided data frame.
#'
#' @param cur_feed_each_bin_st A data frame that contains a time-based structure 
#' where each row corresponds to a different timestamp and other columns capture 
#' the amount of feed in different bins.
#' @param cur_time A specified time for which the count of bins with more than 
#' 0.5 units of feed is to be calculated.
#' 
#' @return An integer representing the number of bins with more than 0.5 units of feed.
total_bin_with_feed <- function(cur_feed_each_bin_st, cur_time) {
  # see how many of the bins has feed > 0.5
  feed_in_bins <- cur_feed_each_bin_st[which(cur_feed_each_bin_st$Time == cur_time), ]
  bin_with_feed_list <- unlist(feed_in_bins[1, c(2:(ncol(feed_in_bins)-2))], use.names = FALSE)
  
  return (length(bin_with_feed_list[which(bin_with_feed_list>0.5)]))
}

#' Calculate Total Number of Occupied Bins with More Than 0.5 Feed
#'
#' This function returns the number of occupied bins that contain more than 0.5 units 
#' of feed at a specified time from provided data frames.
#'
#' @param cur_bin_occupied_st A data frame that captures which bins are occupied at different times.
#' @param cur_feed_each_bin_st A data frame that captures the amount of feed in different bins at different times.
#' @param cur_time A specified time for which the count of occupied bins with more than 
#' 0.5 units of feed is to be calculated.
#' 
#' @return An integer representing the number of occupied bins with more than 0.5 units of feed.
occupied_bin_with_feed <- function(cur_bin_occupied_st, cur_feed_each_bin_st, cur_time) {
  # get a list of bins occupied
  cur_row_bin_occupied <- cur_bin_occupied_st[which(cur_bin_occupied_st$Time == cur_time), c(2:(ncol(cur_bin_occupied_st)-1))]
  bins_occupied_list <- unlist(cur_row_bin_occupied[1,], use.names = FALSE)
  bins_occupied_list2 <- sort(as.character(unique(bins_occupied_list[which(bins_occupied_list>0)])))
  
  # see how many of the bins available has feed > 0.5
  feed_in_bins <- cur_feed_each_bin_st[which(cur_feed_each_bin_st$Time == cur_time), ]
  feed_in_occupied_bins <- feed_in_bins[, which(names(feed_in_bins) %in% bins_occupied_list2)]
  
  # handle special cases when there is only 1 bin occupied, R change the list data type to numeric
  if (length(which(names(feed_in_bins) %in% bins_occupied_list2)) == 1) {
    occupied_bin_with_feed_list <- c(feed_in_occupied_bins)
  } else {
    occupied_bin_with_feed_list <- unlist(feed_in_occupied_bins[1, ], use.names = FALSE)
    
  }
  
  return (length(occupied_bin_with_feed_list[which(occupied_bin_with_feed_list>0.5)]))
}

#' Feeder Occupancy calculation method 1:             
#'                    Occupied bin num                  
#'   -------------------------------------------------- 
#'                    total bin num (30)    
#'
#' @param master_feed_replacement_all A data frame of feed replacements.
#' 
#' @return master_feed_replacement_all after calculating feeder occupancy
method1 <- function(master_feed_replacement_all){
  master_feed_replacement_all$resource_occupancy <- (master_feed_replacement_all$occupied_total_bin/master_feed_replacement_all$total_bin)
  
  return(master_feed_replacement_all)
}

#' Feeder Occupancy calculation method 2:             
#'                    Occupied bin num                  
#'   -------------------------------------------------- 
#'                 total bin with feed num   
#' WARNING: OVERFLOW
#' @param master_feed_replacement_all A data frame of feed replacements.
#' 
#' @return master_feed_replacement_all after calculating feeder occupancy
method2 <- function(master_feed_replacement_all){
  master_feed_replacement_all$resource_occupancy <- (master_feed_replacement_all$occupied_total_bin/master_feed_replacement_all$total_bin_with_feed)
  master_feed_replacement_all$resource_occupancy[which(master_feed_replacement_all$total_bin_with_feed == 0)] <- master_feed_replacement_all$occupied_total_bin[which(master_feed_replacement_all$total_bin_with_feed == 0)] + 1
  master_feed_replacement_all$resource_occupancy[which(master_feed_replacement_all$resource_occupancy >1)] <- 1
  
  return(master_feed_replacement_all)
}

#' Feeder Occupancy calculation method 3:
#'                    Occupied bin num
#'   --------------------------------------------------
#'      total bin num - unoccupied bins that are empty     
#'
#' @param master_feed_replacement_all A data frame of feed replacements.
#' 
#' @return master_feed_replacement_all after calculating feeder occupancy
method3 <- function(master_feed_replacement_all){
  master_feed_replacement_all$resource_occupancy <- (master_feed_replacement_all$occupied_total_bin/(master_feed_replacement_all$total_bin-master_feed_replacement_all$unoccupied_empty_bin))
  
  return(master_feed_replacement_all)
}

#' Feeder Occupancy calculation method 4:             
#'                 Occupied bin with feed num                  
#'  -------------------------------------------------- 
#'                 total bin with feed num   
#' @param master_feed_replacement_all A data frame of feed replacements.
#' 
#' @return master_feed_replacement_all after calculating feeder occupancy
method4 <- function(master_feed_replacement_all){
  master_feed_replacement_all$resource_occupancy <- (master_feed_replacement_all$occupied_bin_with_feed/master_feed_replacement_all$total_bin_with_feed)
  master_feed_replacement_all$resource_occupancy[which(master_feed_replacement_all$total_bin_with_feed == 0)] <- 0
  
  return(master_feed_replacement_all)
}



#' Choose and Apply a Method Based on Method Number
#'
#' This function applies one of the available feeder occupancy calculation methods 
#' to the data frame based on the provided method type number.
#'
#' @param master_feed_replacement_all A data frame that needs processing using one of the methods.
#' @param method_type An integer (1-4) that represents the method type to be applied.
#' 
#' @return A modified version of `master_feed_replacement_all` after applying the selected method.
pick_method <- function(master_feed_replacement_all, method_type) {
  if (method_type == 1) {
    master_feed_replacement_all <- method1(master_feed_replacement_all)
  } else if (method_type == 2) {
    master_feed_replacement_all <- method2(master_feed_replacement_all)
  } else if (method_type == 3) {
    master_feed_replacement_all <- method3(master_feed_replacement_all)
  } else if (method_type == 4) {
    master_feed_replacement_all <- method4(master_feed_replacement_all)
  }
  
  return(master_feed_replacement_all)
}


################################################################################
################# Histogram of Replacement #####################################
################################################################################
#' Plot the Replacement Histogram
#'
#' This function plots the replacement histogram based on feeder occupancy, and hour of the day,
#' and saves the resulting plot.
#'
#' @param master_feed_replacement_all A dataframe containing feed replacement data.
#' @param total_bin_num Total number of bins.
#'
#' @return A dataframe showing the number of replacements for each feeder occupancy bucket.
#'
#' @importFrom dplyr %>% group_by summarise
#' @importFrom ggplot2 ggsave
plot_replace_hist <- function(master_feed_replacement_all, total_bin_num){
  
  # plot number of replacements under different bin Feeder Occupancy  (how many bins are occupied)
  replace_by_density<- replace_by_den(master_feed_replacement_all, total_bin_num)
  
  # plot number of replacements (10 months) under each hour 
  replace_by_hour_per_day <- replace_by_h_per_day(master_feed_replacement_all, total_bin_num)
  
  # calculate number of replacements in each Feeder Occupancy  bucket
  replac_num_each_bucket <- master_feed_replacement_all %>% group_by(resource_occupancy) %>% summarise(n = n())
  replac_num_each_bucket$resource_occupancy <- round(replac_num_each_bucket$resource_occupancy, digits = 5)
  
  ggsave(here("graphs/replace_by_density.png"), plot = replace_by_density, width = 25, height = 13, limitsize = FALSE)
  ggsave(here("graphs/replace_by_hour_per_day.png"), plot = replace_by_hour_per_day, width = 25, height = 13, limitsize = FALSE)
  
  return(replac_num_each_bucket)
}

#' Plot the Number of Replacements by Feeder Occupancy
#'
#' This function returns a ggplot object visualizing the number of replacements 
#' under different feeder occupancy values.
#'
#' @param master_feed_replacement_all A dataframe containing the data.
#' @param total_bin_num The number of bins to use for the histogram.
#' 
#' @return A ggplot object.
#' 
#' @importFrom ggplot2 ggplot aes geom_histogram geom_density theme_classic ylab xlab theme
#' @importFrom viridis scale_fill_viridis
#' @importFrom dplyr %>% group_by summarise
replace_by_den <- function(master_feed_replacement_all, total_bin_num){
  
  temp_plot <- ggplot(master_feed_replacement_all, 
                      aes(x=resource_occupancy)) + 
    geom_histogram(bins = total_bin_num, color = "grey28", fill = "grey58", size = 3) + 
    geom_density() +
    theme_classic() +
    #ggtitle("Number of Replacements by Feeder Occupancy ") +
    ylab("Number of Replacements") +
    xlab("Feeder Occupancy") +
    theme(plot.title = element_text(hjust = 0.5), 
          text = element_text(size = 55),
          axis.text.x = element_text(size = 50)) +
    scale_x_continuous(expand=expansion(mult = c(0, .05))) +
    scale_y_continuous(expand=expansion(mult = c(0, .1)), limits = c(0, 13000))
  
  return(temp_plot)
}

#' Plot the Number of Replacements by Hour per Day
#'
#' This function returns a ggplot object visualizing the number of replacements 
#' under each hour for a 10-month summary.
#'
#' @param master_feed_replacement_all A dataframe containing the data.
#' @param total_bin_num The number of bins to use for the histogram.
#' 
#' @return A ggplot object.
#' 
#' @importFrom ggplot2 ggplot aes geom_histogram theme_classic ylab xlab theme
#' @importFrom viridis scale_fill_viridis
#' @importFrom dplyr %>% group_by summarise
replace_by_h_per_day <- function(master_feed_replacement_all, total_bin_num){
  temp_replacement <- master_feed_replacement_all
  total_days <- length(unique(master_feed_replacement_all$date))
  total_cow <- length(unique(c(master_feed_replacement_all$Reactor_cow, master_feed_replacement_all$Actor_cow)))
  
  temp_plot <- ggplot(master_feed_replacement_all, 
                      aes(y=after_stat(count)/total_days,
                          x=hour, 
                          fill = cut(average_CD_10mon*100, 24))) + 
    geom_histogram(bins = 24) + 
    scale_fill_viridis(name = "Feeder \nOccupancy", discrete = TRUE, direction = -1) +
    theme_classic() +
    #ggtitle("Histogram of Replacements: 10-mon Summary") +
    ylab("Number of Replacements \n / Day / Hour") +
    xlab("Hour of the Day") +
    theme(plot.title = element_text(hjust = 0.5), 
          text = element_text(size = 55),
          axis.text.x = element_text(size = 50)) +
    scale_x_continuous(expand=expansion(mult = c(0, .05))) +
    scale_y_continuous(expand=expansion(mult = c(0, .1)), limits = c(0, 180))
  
  
  return(temp_plot)
}


#' Calculate total number of Replacements Per Hour
#'
#' This function returns a dataframe containing the total number of replacements 
#' and the percentage of replacements for each hour.
#'
#' @param master_feed_replacement_all A dataframe containing the data.
#'
#' @return A dataframe with columns: hour, replacement_num, and replacement_percent.
#'
#' @importFrom stats aggregate
calculate_replacement_per_hour <- function(master_feed_replacement_all) {
  replacement_per_hour <- master_feed_replacement_all
  replacement_per_hour$n <- 1
  replacement_per_hour2 <- aggregate(replacement_per_hour$n, by = list(replacement_per_hour$hour), FUN = sum)
  colnames(replacement_per_hour2) <- c("hour", "replacement_num")
  replacement_per_hour2$replacement_percent <- replacement_per_hour2$replacement_num/nrow(master_feed_replacement_all)
  
  return(replacement_per_hour2)
}


################################################################################
######## Elo Steepness calculation based on Feeder Occupancy ###################
################################################################################
#' Plot Scores with Customizations
#'
#' This function is a modified version of the `plot_scores` function from the `EloSteepness` package.
#' It plots the scores based on the provided data and offers additional customization options.
#'
#' @param x A list containing results from EloSteepness package
#' @param fo Feeder Occupancy percentage to be displayed in the plot title.
#' @param adjustpar Adjust parameter for density estimation. Default is 4.
#' @param color Logical or character vector specifying colors for the plot. If TRUE, uses a sample of 'zissou' colors. If FALSE, uses grayscale. If a character vector, it should match the number of ids.
#' @param subset_ids A character vector of ids to subset. If provided, only these ids will be highlighted in the plot.
#' @param include_others Logical. If TRUE (default), other ids not in `subset_ids` will still be shown but in a different style.
#'
#' @return A plot showing the scores.
plot_scores2 <- function(x,
                         fo,
                         adjustpar = 4,
                         color = TRUE,
                         subset_ids = NULL,
                         include_others = TRUE) {
  correct_object <- FALSE
  if ("cumwinprobs" %in% names(x)) {
    y <- x$cumwinprobs
    res <- matrix(ncol = dim(y)[3], nrow = length(y[, , 1]))
    for (i in seq_len(ncol(res))) {
      res[, i] <- y[, , i]
    }
    xlab <- "summed Elo winning probability"
    correct_object <- TRUE
  }
  if ("norm_ds" %in% names(x)) {
    res <- x$norm_ds
    xlab <- "David's score (normalized)"
    correct_object <- TRUE
  }
  
  if (!correct_object) {
    stop("object 'x' not of correct format")
  }
  
  n_ids <- ncol(res)
  
  if (!is.null(subset_ids)) {
    colnames(res) <- x$ids
    cn_locs <- which(!x$ids %in% subset_ids)
  }
  
  # prep data and set axis limits
  pdata <- apply(res, 2, density, adjust = adjustpar)
  pmax <- max(unlist(lapply(pdata, function(x) max(x$y))))
  xl <- c(0, n_ids - 1)
  yl <- c(0, pmax * 1.05)
  
  # deal with colors
  if (!isFALSE(color) & !isTRUE(color) & !is.null(color)) {
    cols <- NULL
    if (length(color) == n_ids) {
      cols <- color
    }
    if (length(color) == 1) {
      cols <- rep(color, n_ids)
    }
    if (is.null(cols)) {
      stop("colour vector does not match number of ids")
    }
  }
  
  if (isTRUE(color)) {
    cols <- sample(hcl.colors(n = n_ids, "zissou", alpha = 0.7))
  }
  if (isFALSE(color)) {
    cols <- sample(gray.colors(n = n_ids, start = 0.3, end = 0.9, alpha = 0.7))
  }
  
  border_cols <- rep("black", n_ids)
  if (!is.null(subset_ids)) {
    cols[cn_locs] <- NA
    if (!include_others) {
      border_cols[cn_locs] <- NA
    }
  }
  
  # setup
  plot(0, 0, type = "n", xlim = xl, ylim = yl, yaxs = "i", xaxs = "i", axes = FALSE, xlab = "", ylab = "")
  title(main = paste("Feeder Occupancy ", fo, "%", sep = ""), cex.main = 3)
  title(xlab = "Summed Elo Winning Probability", line = 3, cex.lab = 2.5)
  title(ylab = "Density", line = 2, cex.lab = 2.5) # increase font size of y-axis label
  axis(1, at = seq(0, 160, by = 20), labels = seq(0, 160, by = 20), cex.axis = 2, gap.axis = 0.2, mgp = c(2, 0.7, 0), tcl = -0.3)
  
  
  # draw the filled posteriors
  for (i in seq_len(ncol(res))) {
    p <- pdata[[i]]
    p$x[p$x > (n_ids - 1)] <- n_ids - 1
    p$x[p$x < 0] <- 0
    polygon(c(p$x, rev(p$x)), c(rep(0, length(p$x)), rev(p$y)),
            border = NA, col = cols[i])
  }
  
  # draw the contours
  for (i in seq_len(ncol(res))) {
    p <- pdata[[i]]
    p$x[p$x > (n_ids - 1)] <- n_ids - 1
    p$x[p$x < 0] <- 0
    polygon(c(p$x, rev(p$x)), c(rep(0, length(p$x)), rev(p$y)),
            border = border_cols[i], col = NA, lwd = 0.4, xpd = TRUE)
  }
}

#' Calculate Minimum Sample Size Per feeder occupancy Bucket
#'
#' This function calculates the minimum number of replacements among all feeder occupancy buckets.
#' This number will be used as the sample size. It takes a random sample of replacements
#' from each bucket (which may have different numbers of events) to calculate hierarchy.
#'
#' @param res_occupancy_seq A numeric vector representing the resource occupancy (feeder occupancy) sequence.
#' @param replac_num_each_bucket A data frame containing the number of replacements for each bucket. It should have columns 'resource_occupancy' and 'n'.
#'
#' @return A numeric value representing the minimum sample size among all buckets.
sample_size_per_bucket <- function(res_occupancy_seq, replac_num_each_bucket) {
  res_occupancy_seq <- round(res_occupancy_seq, digits = 5)
  replac_num_each_bucket$resource_occupancy <- round(replac_num_each_bucket$resource_occupancy, digits = 5)
  replac_per_grouped_bucket <- data.frame(res_occupancy_seq[2:length(res_occupancy_seq)])
  colnames(replac_per_grouped_bucket) <- c("Max_res_occupancy")
  replac_per_grouped_bucket$replacement_num <- 0
  for (den in 1:nrow(replac_per_grouped_bucket)) {
    start_density <- res_occupancy_seq[den]
    end_density <- res_occupancy_seq[den+1]
    
    # include when Feeder Occupancy is 0
    if (den == 1) {
      cur_replac_num <- sum(replac_num_each_bucket[which((replac_num_each_bucket$resource_occupancy >= start_density) & (replac_num_each_bucket$resource_occupancy <= end_density)),]$n)
      
    } else {
      cur_replac_num <- sum(replac_num_each_bucket[which((replac_num_each_bucket$resource_occupancy > start_density) & (replac_num_each_bucket$resource_occupancy <= end_density)),]$n)
      
    }
    if (end_density == replac_per_grouped_bucket$Max_res_occupancy[den]) {
      replac_per_grouped_bucket$replacement_num[den] <- cur_replac_num
    }
  }
  
  cur_sample_size <- min(replac_per_grouped_bucket$replacement_num)
  return(cur_sample_size)
}

#' Save Plot to PNG File
#'
#' This function saves a plot generated by the `plot_scores2` function to a PNG file.
#'
#' @param elo_steep_result A result object from the EloSteepness analysis.
#' @param feeder_occupancy A numeric value representing the feeder occupancy.
#'
#' @return NULL. The function saves the plot to a PNG file and does not return any value.
save_plot_score <- function(elo_steep_result, feeder_occupancy) {
  file_name <- paste(here("graphs/"), feeder_occupancy, ".png", sep = "")
  png(file_name, width = 1106, height = 550) # set the width and height of the PNG file
  print(plot_scores2(elo_steep_result, feeder_occupancy))
  dev.off() # close the PNG file
}

#' Calculate Elo Steepness Under Different Feeder Occupancies
#'
#' This function calculates the Elo steepness under different feeder occupancies,
#' saves the results, and generates plots for each feeder occupancy.
#'
#' @param master_feed_replacement_all A data frame containing replacement data.
#' @param master_comb A data frame containing combined data.
#' @param res_occupancy_seq A numeric vector representing the resource occupancy sequence.
#' @param sample_size A numeric value indicating the sample size.
#'
#' @return NULL. The function saves various results to `.rda` files and does not return any value.
elo_steepness_competition <- function(master_feed_replacement_all, master_comb, res_occupancy_seq, sample_size) {
  for (cur_den in 2:length(res_occupancy_seq)) {
    print(paste0("cur_den: ", cur_den))
    # only the information for events happened in the current Feeder Occupancy 
    if (cur_den == 2) {
      # include when Feeder Occupancy is 0
      temp_replacement_prep <- master_feed_replacement_all[which((master_feed_replacement_all$resource_occupancy >= res_occupancy_seq[cur_den-1]) & (master_feed_replacement_all$resource_occupancy <= res_occupancy_seq[cur_den])),]
      
    } else {
      temp_replacement_prep <- master_feed_replacement_all[which((master_feed_replacement_all$resource_occupancy > res_occupancy_seq[cur_den-1]) & (master_feed_replacement_all$resource_occupancy <= res_occupancy_seq[cur_den])),]
      
    }
    
    
    # record number of replacements under each bucket
    resource_occupancy <- res_occupancy_seq[cur_den]
    replacement_num <- nrow(temp_replacement_prep)
    num_replacement_bucket_temp <- data.frame(resource_occupancy, replacement_num)
    temp_replacement_prep$start_density <- res_occupancy_seq[cur_den-1]
    temp_replacement_prep$end_density <- res_occupancy_seq[cur_den]
    
    # randomly sample certain replacement events, make sure each cow show up at least once
    temp_replacement_list <- random_sample(temp_replacement_prep, sample_size)
    
    # summarize for all replacements events happened under current Feeder Occupancy , what's the distribution of replacement events across time by hour
    temp_replacement_by_hour <- temp_replacement_list %>% group_by(hour) %>% summarise(n = n())
    names(temp_replacement_by_hour)[names(temp_replacement_by_hour) == 'n'] <- "replacement_num"
    temp_replacement_by_hour$resource_occupancy <- resource_occupancy
    
    #summarize replacements by day
    replacement_by_day <- temp_replacement_list %>% group_by(date) %>% summarise(n = n())
    names(replacement_by_day)[names(replacement_by_day) == 'n'] <- "replacement_num"
    replacement_by_day$resource_occupancy <- resource_occupancy
    
    # because feeding visit could across hours, start of a feeding visit could be 1:50 but the end is 2:10
    start_date_hour <- temp_replacement_list[, c("date", "hour")]
    colnames(start_date_hour) <- c("date", "start_hour")
    start_date_hour <- unique(start_date_hour)
    end_date_hour <- start_date_hour
    colnames(end_date_hour) <- c("date", "end_hour")
    temp_merge_start <- merge(master_comb, start_date_hour)
    temp_merge_end <- merge(master_comb, end_date_hour)
    temp_master_comb <- merge(temp_merge_start, temp_merge_end, all = TRUE) 
    temp_master_comb <- unique(temp_master_comb)
    temp_master_comb <- temp_master_comb[, c("Cow", "Bin", "Start", "End", "date", "start_hour", "end_hour")]
    
    # count number of times each cow is an actor/reactor
    # count frequency of being an actor each day
    count_actor <- temp_replacement_list %>% group_by(date, Actor_cow) %>% summarise(n = n())
    names(count_actor)[names(count_actor) == 'n'] <- "actor_freq"
    names(count_actor)[names(count_actor) == 'Actor_cow'] <- "Cow"
    count_actor$resource_occupancy <- resource_occupancy
    # count frequency of being an reactor each day, under current Feeder Occupancy 
    count_reactor <- temp_replacement_list %>% group_by(date, Reactor_cow) %>% summarise(n = n())
    names(count_reactor)[names(count_reactor) == 'n'] <- "reactor_freq"
    names(count_reactor)[names(count_reactor) == 'Reactor_cow'] <- "Cow"
    count_reactor$resource_occupancy <- resource_occupancy
    # count frequency of this cow having feeding visits 
    count_feeding_visit <- temp_master_comb %>% group_by(date, Cow) %>% summarise(n = n())
    names(count_feeding_visit)[names(count_feeding_visit) == 'n'] <- "feeding_visits_in_2h"
    count_feeding_visit$resource_occupancy <- resource_occupancy
    # merge all sheets together
    count_actor_reactor_visit <- merge(count_actor, count_reactor, all = TRUE)
    count_actor_reactor_visit[is.na(count_actor_reactor_visit)] <- 0
    count_actor_reactor_visit$total_replacement_events <- count_actor_reactor_visit$actor_freq + count_actor_reactor_visit$reactor_freq
    count_actor_reactor_visit <- merge(count_actor_reactor_visit, count_feeding_visit, all = TRUE)
    count_actor_reactor_visit[is.na(count_actor_reactor_visit)] <- 0
    
    
    ## Get all the days in the trial period (also the days which are excluded) ##
    alldays <- seq.Date(from=min(temp_master_comb$date),to=max(temp_master_comb$date),by="day") #set the period you want to use here
    
    #all the cows present in the trial period
    allcows <- unique(temp_master_comb$Cow)
    
    #Get the cow presence data for all days
    presence_comb=data.frame(matrix(0,length(alldays),length(allcows)+1))
    presence_comb[,1]=alldays
    colnames(presence_comb)=c("Date",allcows)
    
    for(ro in 1:length(alldays))
    {
      presence_comb[ro,match(unique(temp_master_comb[which(temp_master_comb$date==alldays[ro]),c("Cow")]),colnames(presence_comb))]=1 #show cows present for each day with a 1
    }
    
    ##################################################################
    #### Get time ordered replacement data in Actor-Receiver form ####
    ##################################################################
    ## Order replacements
    elo.repl.list <- temp_replacement_list[order(temp_replacement_list$Time),c("Actor_cow", "Reactor_cow","Time", "Bin")]
    colnames(elo.repl.list)=c("winner","loser","time","bin")
    
    
    ######################### construction ###############################
    ## test elo steepness
    elo_baysian_result <- elo_steepness_from_sequence(winner=as.character(elo.repl.list$winner),
                                                      loser=as.character(elo.repl.list$loser),
                                                      algo="fixed_sd",
                                                      cores = 4,
                                                      chains = 4,
                                                      iter = 10000, 
                                                      warmup = 2000,
                                                      seed = 800,
                                                      silent = FALSE,
                                                      control = list(adapt_delta = 0.99))
    steep_mean <- round(mean(elo_baysian_result[["steepness"]]), digits = 2)
    steep_sd <- round(sd(elo_baysian_result[["steepness"]]), digits = 2)
    elo_steep_df <- data.frame(round(resource_occupancy, digits = 2), steep_mean, steep_sd)
    colnames(elo_steep_df) <- c("resource_occupancy", "steepness_mean", "steepness_SD")
    
    save_plot_score(elo_baysian_result, round(resource_occupancy, digits = 2))
    
    save(elo_baysian_result, file = paste(here("data/results/elo_baysian_result_"), round(resource_occupancy, digits = 2), ".rda", sep = ""))
    
    if (cur_den == 2){
      count_presence <- count_actor_reactor_visit
      replace_num_by_hour_master <- temp_replacement_by_hour
      replacement_by_day_master <- replacement_by_day
      replacement_sampled_master <- temp_replacement_list
      master_steepness <- elo_steep_df
    } else {
      count_presence <- rbind(count_presence, count_actor_reactor_visit)
      replace_num_by_hour_master <- rbind(replace_num_by_hour_master, temp_replacement_by_hour)
      replacement_by_day_master <- rbind(replacement_by_day_master, replacement_by_day)
      replacement_sampled_master <- rbind(replacement_sampled_master, temp_replacement_list)
      master_steepness <- rbind(master_steepness, elo_steep_df)
    }
  }
  
  save(replace_num_by_hour_master, file = paste(here("data/results/", "replace_num_by_hour_master.rda", sep = "")))
  save(count_presence, file = paste(here("data/results/", "count_presence.rda", sep = "")))
  save(replacement_by_day_master, file = paste(here("data/results/", "replacement_by_day_master.rda", sep = "")))
  save(replacement_sampled_master, file = paste(here("data/results/", "replacement_sampled_master.rda", sep = "")))
  save(master_steepness, file = paste(here("data/results/", "master_steepness.rda", sep = "")))
  
  cache("master_steepness")
  cache("replacement_sampled_master")

}

#' Randomly Sample Replacement Events
#'
#' This function randomly samples replacement events from the provided data, ensuring
#' that each cow appears at least once, either as an actor or a reactor.
#'
#' @param temp_replacement_prep A data frame containing replacement data. It should have columns 'Reactor_cow' and 'Actor_cow'.
#' @param sample_size A numeric value indicating the desired sample size.
#'
#' @return A data frame containing the sampled replacement events.
random_sample <- function(temp_replacement_prep, sample_size) {
  
  set.seed(1)
  # make sure each cow show up at least once 
  sample1_sub1 <- temp_replacement_prep %>% group_by(Reactor_cow) %>% sample_n(1)
  sample1_sub2 <- temp_replacement_prep %>% group_by(Actor_cow) %>% sample_n(1)
  sample1 <- unique(rbind(sample1_sub1, sample1_sub2))
  already_sampled <- nrow(sample1)
  #print(already_sampled)
  to_be_sampled_num <- sample_size - already_sampled
  # mark the rows that was already sampled, and isolate those that has not been sampled
  sample1$sampled <- 1
  not_sampled <- merge(temp_replacement_prep, sample1, all = TRUE)
  not_sampled2 <- not_sampled[which(is.na(not_sampled$sampled)),]
  not_sampled2$sampled <- NULL # delete helper column
  sample2 <- sample_n(not_sampled2, size = to_be_sampled_num)
  temp_replacement_list <- unique(rbind(sample1, sample2))
  
  return(temp_replacement_list)
}

################################################################################
############################### Steepness Plot #################################
################################################################################
#' Plot Elo Steepness by Feeder Occupancy
#'
#' This function creates a plot that visualizes the changes in Elo steepness 
#' as Feeder Occupancy increases.
#'
#' @param master_steepness A data frame containing the Elo steepness data. It should have columns 'resource_occupancy' and 'steepness_mean'.
#'
#' @return A ggplot object visualizing the changes in Elo steepness by Feeder Occupancy.
elo_steepness_by_competition_plot <- function(master_steepness) {
  
  steepness_plot <- ggplot(master_steepness, aes(x=resource_occupancy, y = steepness_mean)) + 
    geom_point(aes(y = steepness_mean), size = 10, color = "royal blue") +
    geom_smooth(method = "lm", se = FALSE, size= 2, color = "midnight blue", fullrange = TRUE) +
    labs(y= "Elo Steepness", x = "Feeder Occupancy") +
    theme_classic() +
    #ggtitle(paste("Elo Standard Deviation by \n Feeder Occupancy :", cur_date, sep = " ")) + 
    theme(text = element_text(size = 55), axis.text.x = element_text(size = 50)) +
    #scale_x_continuous(expand=expansion(mult = c(0, .05))) +
    scale_y_continuous(expand=expansion(mult = c(0, .1)), limits = c(0, 0.63))
  
  
  return(steepness_plot)
}

#' Save Elo Steepness Plot to PNG File
#'
#' This function saves the plot visualizing the changes in Elo steepness 
#' as Feeder Occupancy increases to a PNG file.
#'
#' @param master_steepness A data frame containing the Elo steepness data. It should have columns 'resource_occupancy' and 'steepness_mean'.
#'
#' @return NULL. The function saves the plot to a PNG file and does not return any value.
elo_steepness_plot <- function(master_steepness) {
  steepness_plot <- elo_steepness_by_competition_plot(master_steepness)
  file_name = here("graphs/Elo_steepness_by_competition.png")
  ggsave(file_name, plot = steepness_plot, width = 15, height = 13, limitsize = FALSE)
  
}
