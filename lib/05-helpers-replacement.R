#' Sort and filter data based on bins
#' 
#' @param cur_data The data frame containing feeding/drinking data
#' @return A data frame filtered by bins
process_bins <- function(cur_data, replacement_threshold = replacement_threshold) {
  sorted_data <- cur_data[order(cur_data$Bin, cur_data$Start, cur_data$End),]
  sorted_data <- sorted_data[, c("Cow", "Bin", "Start", "End", "date")]
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
    
    cur_data_bin <- cur_data_bin[, -c(3,6)]
    colnames(cur_data_bin) <- c("Reactor_cow", "Bin", "Time", "date", "Actor_cow", "Bout_interval")
    
    master_df <- rbind(master_df, cur_data_bin)
  }
  
  return(master_df)
}

#' Main function to process feeding data
#' 
#' @param feeding_data The data frame containing feeding data
#' @return A processed data frame
process_feeding_data <- function(feeding_data) {
  processed_data <- process_bins(feeding_data)
  return(processed_data)
}

# Example usage:
# processed_result <- process_feeding_data(master_feeding3)
