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