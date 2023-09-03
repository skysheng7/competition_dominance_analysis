

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

#' Generate empty Synchronization Matrices for Feed/water Data
#'
#' This function takes a list of feed data and creates synchronization matrices for time-cow, 
#' time-bin, and time-feed based on each list element.
#'
#' @param data_list A list of feed / water data frames grouped by date.
#' @param min_feed_bin Minimum feeder bin value to keep.
#' @param max_feed_bin Maximum feeder bin value to keep.
#' @return A list containing three lists of matrices: 
#'         synch_master_cow, synch_master_bin, synch_master_feed.
empty_synch_matrix <- function(data_list, min_feed_bin, max_feed_bin) {
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

#' Initialize and Process Synchronization Matrices
#'
#' This function initializes synchronization matrices and processes feed/water data
#' to populate the matrices based on each list element.
#' It process MATRIX1 (synch_master_cow): Time X CowID for which cow is eating/drinking
#' AND MARTRIX2 (synch_master_bin): Time X CowID for which bin the cow is at
#' AND MATRIX3 (synch_master_feed): Time X Bin for how much feed/watr is at each bin at each second
#'
#' @param data_list A list of data frames.
#' @param min_feed_bin Minimum value of the feed bin.
#' @param max_feed_bin Maximum value of the feed bin.
#'
#' @return A list containing three matrices: 
#'         synch_master_cow, synch_master_bin, synch_master_feed.
matrix_initialize <- function(data_list, min_feed_bin, max_feed_bin) {
  results <- empty_synch_matrix(data_list, min_feed_bin, max_feed_bin)
  synch_master_cow <- results$synch_master_cow
  synch_master_bin <- results$synch_master_bin
  synch_master_feed <- results$synch_master_feed
  
  # go through every single day
  for (y in 1:length(data_list)) {
    cur_data <- data_list[[y]]
    cur_data <- cur_data[order(cur_data$Start, cur_data$End), ]
    cow_list <- sort(unique(cur_data$Cow))
    bin_list <- seq(min_feed_bin, max_feed_bin, by = 1)
    
    ### Process MATRIX1 (synch_master_cow): Time X CowID for which cow is eating/drinking
    ### AND MARTRIX2 (synch_master_bin): Time X CowID for which bin the cow is at
    ### AND MATRIX3 (synch_master_feed): Time X Bin for how much feed/watr is at each bin at each second
    # go through the feed or water datasheet, mark down a "1" on the time, if the cow is feeding/drinking at that second
    for (o in 1:nrow(cur_data)) {
      cur_cow <- cur_data$Cow[o]
      index_cow <- match(cur_cow, cow_list)+1
      cur_start <- cur_data$Start[o]
      cur_end <- cur_data$End[o]
      cur_dur <- cur_data$Duration[o]
      cur_bin <- cur_data$Bin[o]
      index_bin <- match(cur_bin, bin_list) + 1
      start_weight <- cur_data$Startweight[o]
      end_weight <- cur_data$Endweight[o]
      start_row_number <- which(synch_master_cow[[y]]$Time == cur_start)
      end_row_number <- which(synch_master_cow[[y]]$Time == cur_end)
      weight_list <- round(seq(start_weight, end_weight, length.out = (end_row_number - start_row_number + 1)), digits = 1)
      
      
      # process matrix 1, time X CowID on cow
      synch_master_cow[[y]][(start_row_number:end_row_number) , index_cow] <- 1
      # process matrix 2, time X CowID on bin number
      synch_master_bin[[y]][(start_row_number:end_row_number) , index_cow] <- cur_bin
      # process matrix 3, time X Bin
      synch_master_feed[[y]][(start_row_number:end_row_number), index_bin] <- weight_list
    }
  }
  
  return(list(synch_master_cow = synch_master_cow,
              synch_master_bin = synch_master_bin,
              synch_master_feed = synch_master_feed))
}

#' Process the current synchronization data to replace NA values and compute total feed
#'
#' This function processes the provided `cur_synch` data matrix. 
#' It replaces the initial NA values of each column with the first non-NA value in that column.
#' Then, it replaces any subsequent NA values in each column with the last observed non-NA value in that column.
#' Finally, it calculates the total feed in all bins and adds it as a new column.
#'
#' @param cur_synch A matrix/dataframe representing the current synchronization data.
#'                  The first column is expected to be 'Time', and the other columns represent bins.
#'                  The matrix should have NA values where feed data is not available.
#' @param total_bin An integer indicating the total number of bins.
#'
#' @return A matrix/dataframe where the NA values in the bin columns are replaced,
#'         and a new column `totalFeed` is added which represents the sum of feeds in all bins.
process_cur_synch <- function(cur_synch, total_bin) {
  
  # Set the first row of cur_synch if it's NA.
  # Use apply to go column by column and replace NA with the first non-NA value.
  first_non_na <- apply(cur_synch[, 2:(ncol(cur_synch) - 1)], 
                        2, function(x) x[which(!is.na(x))[1]])
  cur_synch[1, 2:(ncol(cur_synch) - 1)] <- ifelse(is.na(cur_synch[1, 2:(ncol(cur_synch) - 1)]),
                                                  first_non_na, 
                                                  cur_synch[1, 2:(ncol(cur_synch) - 1)])
  
  # Replace NA values with the last observed non-NA value.
  # Do this column by column.
  cur_synch[, 2:(ncol(cur_synch) - 1)] <- apply(cur_synch[, 2:(ncol(cur_synch) - 1)], 2, na.locf)
  
  # Add a new column calculating the total feed in all bins.
  cur_synch$totalFeed <- rowSums(cur_synch[, 2:(total_bin + 1)], na.rm = TRUE)
  
  return(cur_synch)
}


#' Process matrices and add derived columns.
#'
#' This function processes a list of matrices, adds several derived columns like total number of cows,
#' total bin occupied, and date, and then returns processed versions of the matrices.
#' 
#' @param data_list A list of data frames to process.
#' @param min_feed_bin The minimum value of the feed bin.
#' @param max_feed_bin The maximum value of the feed bin.
#'
#' @return A list containing three processed lists of data frames: synch_master_cow2, synch_master_bin2, and synch_master_feed2.
matrix_process <- function(data_list, min_feed_bin, max_feed_bin) {
  total_bin <- max_feed_bin - min_feed_bin + 1
  results <- matrix_initialize(data_list, min_feed_bin, max_feed_bin)
  synch_master_cow <- results$synch_master_cow
  synch_master_bin <- results$synch_master_bin
  synch_master_feed <- results$synch_master_feed
  
  # create duplicates
  synch_master_cow2 <- synch_master_cow
  synch_master_bin2 <- synch_master_bin
  synch_master_feed2 <- synch_master_feed
  
  for (i in 1:length(synch_master_cow)) {
    # calculate how many cows are present eating at each second
    synch_master_cow[[i]]$total_cow_num <- rowSums(synch_master_cow[[i]][, 2:ncol(synch_master_cow[[i]])], na.rm = TRUE)
    synch_master_cow[[i]]$total_bin_occupied <- synch_master_cow[[i]]$total_cow_num
    synch_master_cow[[i]]$empty_bin_num <- total_bin - synch_master_cow[[i]]$total_bin_occupied
    
    
    # delete the time when no cow is eating
    records_to_keep <- which(synch_master_cow[[i]]$total_cow_num > 0)
    synch_master_cow2[[i]] <- synch_master_cow[[i]][records_to_keep, ]
    synch_master_bin2[[i]] <- synch_master_bin[[i]][records_to_keep, ]
    synch_master_feed2[[i]] <- synch_master_feed[[i]][records_to_keep, ]
    
    
    # add date
    synch_master_cow2[[i]]$date <- date(synch_master_cow2[[i]]$Time)
    synch_master_bin2[[i]]$date <- date(synch_master_bin2[[i]]$Time)
    synch_master_feed2[[i]]$date <- date(synch_master_feed2[[i]]$Time)
    
    # fill in feed amount at each second at each bin
    synch_master_feed2[[i]] <- process_cur_synch(synch_master_feed2[[i]], total_bin)
  }
  
  return(list(synch_master_cow2 = synch_master_cow2,
              synch_master_bin2 = synch_master_bin2,
              synch_master_feed2 = synch_master_feed2))
}




