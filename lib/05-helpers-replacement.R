#' identify and recprd replacements for a single day. replacements are identified if the time interval
#' between the first cow leaving and the next cow entering is < 26s
#' 
#' @param cur_data The data frame containing feeding/drinking data
#' @param replacement_threshold threshold for replacement behaviours in seconds. 
#' the interval between the first cow leaving and the next cow entering
#' @return A data frame filtered by bins
record_replacement_1day <- function(cur_data, replacement_threshold = 26) {
  sorted_data <- cur_data[order(cur_data$Bin, cur_data$Start, cur_data$End),]
  sorted_data <- sorted_data[, c("Cow", "Bin", "Start", "End")]
  sorted_data$date <- date(sorted_data$Start)
  bin_list <- sort(unique(sorted_data$Bin))
  
  master_df <- data.frame()
  
  for (cur_bin in bin_list) {
    cur_data_bin <- sorted_data[which(sorted_data$Bin == cur_bin),]
    
    next_start_list <- cur_data_bin$Start[2:nrow(cur_data_bin)]
    next_cow_list <- cur_data_bin$Cow[2:nrow(cur_data_bin)]
    cur_data_bin <- cur_data_bin[-nrow(cur_data_bin), ]
    
    cur_data_bin$next_start <- next_start_list
    cur_data_bin$next_cow <- next_cow_list
    
    time_interval <- cur_data_bin$End %--% cur_data_bin$next_start
    cur_data_bin$time_dif <- as.duration(time_interval)
    
    replace_cutoff <- as.duration(paste0(replacement_threshold, "s"))
    cur_data_bin <- cur_data_bin[
      which((cur_data_bin$time_dif <= replace_cutoff) & 
              (cur_data_bin$Cow != cur_data_bin$next_cow)),]
    
    cur_data_bin <- cur_data_bin[, c("Cow", "Bin", "End", "date", "next_cow", "time_dif")]
    # the time of replacement is the end time of the reactor cow's feeding event
    colnames(cur_data_bin) <- c("Reactor_cow", "Bin", "Time", "date", "Actor_cow", "Bout_interval")
    
    master_df <- rbind(master_df, cur_data_bin)
  }
  
  return(master_df)
}

#' identify and record replacements for all the dates in a list. replacements are identified if the time interval
#' between the first cow leaving and the next cow entering is < 26s
#' 
#' @param data_list The data frame containing feeding/drinking data
#' @param replacement_threshold threshold for replacement behaviours in seconds. 
#' the interval between the first cow leaving and the next cow entering
#' 
#' @return a list of dataframes containing replacements for each day
record_replacement_allDay <- function(data_list, replacement_threshold) {
  replacement_list_by_date <- list()
  for (i in 1:length(data_list)) {
    cur_data <- data_list[[i]]
    replacement_list_by_date[[i]] <- record_replacement_1day(cur_data, replacement_threshold)
    names(replacement_list_by_date)[i] <- names(data_list)[i]
  }

  return(replacement_list_by_date)
}


check_aliby <- function(replacement_list_by_date, all_comb2) {
  
}
