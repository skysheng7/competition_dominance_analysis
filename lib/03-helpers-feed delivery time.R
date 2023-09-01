#' Create Default Feed Time Sheet
#'
#' This function creates a default feed time sheet based on the provided feed data.
#' All time-related columns are initialized with NA, while the columns indicating if 
#' the delivery was found are initialized with an empty string.
#'
#' @param all_feed A list of feed data, where each element is a data frame representing feed details for a specific date.
#' @return A data frame with default feed time columns.
#' @export
create_default_feed_time_sheet <- function(all_feed) {
  
  # Extract date list from the feed data
  date_list <- names(all_feed)
  
  # Create the data frame with default columns
  time_interval_after_feed_added <- data.frame(
    date = date_list,
    morning_feed_add_start = NA,
    morning_90min_after_feed = NA,
    morning_2h_after_feed = NA,
    morning_3h_after_feed = NA,
    afternoon_feed_add_start = NA,
    afternoon_90min_after_feed = NA,
    afternoon_2h_after_feed = NA,
    afternoon_3h_after_feed = NA,
    morning_feed_delivery_no_found = "",
    afternoon_feed_delivery_no_found = "",
    noon_feed_add_start = NA,
    noon_90min_after_feed = NA,
    noon_2h_after_feed = NA,
    noon_3h_after_feed = NA,
    noon_feed_delivery_found = ""
  )
  
  return(time_interval_after_feed_added)
}


#' Identify feed added times in a sheet
#'
#' @param sheet The current sheet to check for feed additions.
#' @return The sheet with an added 'feed_added' column.
identify_feed_add_times <- function(sheet) {
  # sort by bin number and start time
  sheet <- sheet[order(sheet$Bin, sheet$Start),]
  sheet$feed_added <- 0
  
  # if the bin number didn't change, but feed in the bin increased by more than 10 kg, then this is when feed get added
  for (k in 2:nrow(sheet)) {
    if ((sheet$Bin[k] == sheet$Bin[k-1]) & ((sheet$Startweight[k] - sheet$Endweight[k-1]) > 10)) {
      sheet$feed_added[k] <- 1
    }
  }
  
  return(sheet)
}

#' Extract and update feed times based on identified feed addition
#'
#' @param sheet The current sheet with identified feed additions.
#' @param cur_date The specific date for the time intervals.
#' @param time_zone Time zone to be used in date-time operations
#' 
#' @return A list of feed times for morning, afternoon, and noon.
extract_feed_times <- function(sheet, cur_date, time_zone) {
  feed_add_time <- sheet[which(sheet$feed_added == 1),]
  
  feed_add_morning <- data.frame()
  special_feed_add <- data.frame()
  feed_add_afternoon <- data.frame()
  
  # feed delivery in the morning
  feed_add_morning <- feed_add_time[which(feed_add_time$Start < ymd_hms(paste(cur_date, "11:00:00"), tz=time_zone)), ] 
  feed_add_morning <- feed_add_morning[order(feed_add_morning$Start),]
  
  # if there are feed add time in the afternoon after 11AM
  temp <- feed_add_time[which(feed_add_time$Start >= ymd_hms(paste(cur_date, "11:00:00"), tz=time_zone)), ]
  if (nrow(temp) > 0 ) {
    # sometimes feed was added at noon. Handle those cases
    special_feed_add <- feed_add_time[which((feed_add_time$Start >= ymd_hms(paste(cur_date, "11:00:00" ), tz=time_zone)) & 
                                              (feed_add_time$Start <= ymd_hms(paste(cur_date, "14:00:00" ), tz=time_zone))), ]
    
    # feed delivery in the afternoon
    feed_add_afternoon <- feed_add_time[which(feed_add_time$Start > ymd_hms(paste(cur_date, "14:00:00"), tz=time_zone)), ]
    
    # sort by time
    feed_add_afternoon <- feed_add_afternoon[order(feed_add_afternoon$Start),]
    special_feed_add <- special_feed_add[order(special_feed_add$Start),]
  }
  
  return(list(morning = feed_add_morning, afternoon = feed_add_afternoon, noon = special_feed_add))
}

#' Update feed time data sheet based on extracted feed times
#'
#' @param time_interval_after_feed_added The data sheet with default feed times.
#' @param feed_times A list of feed times for morning, afternoon, and noon.
#' @param i the index
#' @return The updated data sheet.
update_feed_time_sheet <- function(time_interval_after_feed_added, feed_times, i) {
  feed_add_morning <- feed_times$morning
  feed_add_afternoon <- feed_times$afternoon
  special_feed_add <- feed_times$noon
  
  # TODO
  # Logic to update the time_sheet based on feed_times...
  return(time_sheet)
}


feed_delivery_check <- function(all_feed) {
  time_interval_after_feed_added <- create_default_feed_time_sheet(all_feed)
  for (i in 1:length(all_feed)) {
    cur_date <- as.character(date(all_feed[[i]]$Start[1]))
    cur_sheet <- all_feed[[i]]
    
    cur_sheet <- identify_feed_add_times(cur_sheet)
    feed_times <- extract_feed_times(cur_sheet, cur_date, time_zone)
    time_interval_after_feed_added <- update_feed_time_sheet(time_interval_after_feed_added, feed_times, i)
  }
  
  return(time_interval_after_feed_added)
}

