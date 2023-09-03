

#' Create a time sequence from start to end, by seconds
#'
#' @param cur_data A data frame containing feeding data, or drinking data or both.
#' @return A vector of time sequence.
create_time_sequence <- function(cur_data) {
  total_start <- min(cur_data$Start)
  total_end <- max(cur_data$End)
  dateTime_seq <- seq(total_start, total_end, by = "sec")
  return(dateTime_seq)
}

#' create MATRIX1: empty matrix preperation: CowID X Time for which cow is eating/drinking
#' create a matrix where x axis contains cow ID, and y axis contains time (every seconds)
#'
#' @param cur_data A data frame containing feeding data, or drinking data or both.
#' @param dateTime_seq A vector of time sequence.
#' @return A matrix of Time and cowID.
prepare_time_cow_matrix <- function(cur_data, dateTime_seq) {
  cow_list <- sort(unique(cur_data$Cow))
  col_num <- length(cow_list) + 1
  synch_master_cow <- data.frame(matrix(0, length(dateTime_seq), col_num))
  colnames(synch_master_cow) <- c("Time", cow_list)
  synch_master_cow$Time <- dateTime_seq
  return(synch_master_cow)
}

#' create MARTRIX2: empty matrix preperation: Time X CowID for which bin the cow is at
#'
#' @param cow_time_matrix A matrix of CowID and Time.
#' @return A matrix of Time and CowID.
prepare_time_bin_matrix <- function(cow_time_matrix) {
  return(cow_time_matrix)
}

#' create MATRIX3: Time X Bin for how much feed is at each bin at each second
#'
#' @param dateTime_seq A vector of time sequence.
#' @param min_feed_bin Minimum feeder bin value to keep.
#' @param max_feed_bin Maximum feeder bin value to keep.
#' @return A matrix of Time and Feed amount in each bin.
prepare_time_feed_matrix <- function(dateTime_seq, min_feed_bin, max_feed_bin) {
  bin_list <- seq(min_feed_bin, max_feed_bin, by = 1)
  col_num <- length(bin_list) + 1
  synch_master_feed <- data.frame(matrix(NA, length(dateTime_seq), col_num))
  colnames(synch_master_feed) <- c("Time", bin_list)
  synch_master_feed$Time <- dateTime_seq
  return(synch_master_feed)
}

#' Generate Synchronization Matrices for Feed/water Data
#'
#' This function takes a list of feed data and creates synchronization matrices for time-cow, 
#' time-bin, and time-feed based on each list element.
#'
#' @param data_list A list of feed / water data frames grouped by date.
#'
#' @return A list containing three lists of matrices: 
#'         synch_master_cow, synch_master_bin, synch_master_feed.
empty_synch_matrix <- function(data_list) {
  date_list <- names(data_list)
  synch_master_cow <- list()
  synch_master_bin <- list()
  synch_master_feed <- list()
  for (y in 1:length(data_list)) {
    cur_data <- data_list[[y]]
    cur_data <- cur_data[order(cur_data$Start, cur_data$End), ]
    dateTime_seq <- create_time_sequence(cur_data)
    
    cow_time_matrix <- prepare_time_cow_matrix(cur_data, dateTime_seq)
    time_bin_matrix <- prepare_time_bin_matrix(cow_time_matrix)
    time_feed_matrix <- prepare_time_feed_matrix(dateTime_seq, min_feed_bin, max_feed_bin)
    
    synch_master_cow[[y]] <- cow_time_matrix
    synch_master_bin[[y]] <- time_bin_matrix
    synch_master_feed[[y]] <- time_feed_matrix
    
    # rename the list name
    names(synch_master_cow)[y] <- names(data_list)[y]
    names(synch_master_bin)[y] <- names(data_list)[y]
    names(synch_master_feed)[y] <- names(data_list)[y]
  }
  
  return(list(synch_master_cow = synch_master_cow,
              synch_master_bin = synch_master_bin,
              synch_master_feed = synch_master_feed))
}


