################################################################################
########################### Dyadic analysis ####################################
################################################################################
#' Calculate Total Unique Dyadic Relationships Over 10 Months
#'
#' This function calculates the total number of unique dyads 
#' possible over a 10-month period from a list of data frames in a dynamic group.
#'
#' @param clean_comb_list2 A list of data frames where each data frame represents 
#' data for a specific day and contains a column named 'Cow' with cow IDs.
#' 
#' @return A single integer value representing the total number of unique dyadic relationships.
total_dyad_long_term <- function(clean_comb_list2) {
  for (i in 1:length(clean_comb_list2)) {
    cur_day <- clean_comb_list2[[i]]
    cow_list <- unique(cur_day$Cow)
    actor_cow <- data.frame(cow_list)
    colnames(actor_cow) <- c("actor_cow")
    reactor_cow <- data.frame(cow_list)
    colnames(reactor_cow) <- c("reactor_cow")
    temp_track_dyad <- merge(actor_cow, reactor_cow, all = TRUE)
    temp_track_dyad2 <- temp_track_dyad[which(temp_track_dyad$actor_cow!= temp_track_dyad$reactor_cow),]
    for (k in 1:nrow(temp_track_dyad2)) {
      temp_track_dyad2$dyadID[k] <- paste(temp_track_dyad2$actor_cow[k], temp_track_dyad2$reactor_cow[k], sep = "-")
    }
    
    temp_dyad_list <- unique(temp_track_dyad2$dyadID)
    
    if (i == 1) {
      dyad_list <- temp_dyad_list
    } else {
      dyad_list <- unique(c(dyad_list, temp_dyad_list))
    }
  }
  
  dyad_list <- sort(dyad_list)
  total_dyad <- length(dyad_list)
  total_unique_dyad <- total_dyad/2
  
  return(total_unique_dyad)
}

#' Analyze Dyadic Relationships Over Long Term
#'
#' This function analyzes the directionality and frequency of interactions 
#' between pairs of entities over a long term, the percentage of unknown dyads 
#' (dyads where 2 cows could have interacted because they were in the pen at the 
#' same time, but did not interact)
#'on different resource occupancy levels.
#'
#' @param master_feed_replacement_all A dataframe containing replacement data.
#' @param res_occupancy_seq A vector of resource occupancy levels.
#' @param group_by An integer specifying how many resource occupancy levels should be grouped together.
#' @param total_dyad_possible_num An integer specifying the total possible number of dyads.
#' 
#' @return A list containing two data frames: 
#' \itemize{
#'   \item The first data frame contains the directionality of interactions for each dyad.
#'   \item The second data frame contains the percentage of unknown dyads for each resource occupancy level.
#' }
dyad_relationship_long_term <- function(master_feed_replacement_all, res_occupancy_seq, group_by, total_dyad_possible_num) {
  sub_feed_replacement <- master_feed_replacement_all[, c("date", "Time", "Actor_cow", "Reactor_cow", "resource_occupancy")]
  cur_period_replcement <- sub_feed_replacement
  
  # iterate through each level of CD
  # there is not enough number of replacements under each CD level if we have 25 levels of CD
  # we group every multiple levels of CD together to have enough number of replacements (> 10 * 48)
  k = 1
  while (k < length(res_occupancy_seq)) {
    if ((k+group_by) > length(res_occupancy_seq)) {
      start_density <- res_occupancy_seq[k]
      end_density <- res_occupancy_seq[length(res_occupancy_seq)]
    } else {
      start_density <- res_occupancy_seq[k]
      end_density <- res_occupancy_seq[k+group_by]
    }
    
    # get all replacements under current period of stable group under current CD 
    cur_period_cur_cd_replacement <- cur_period_replcement[which((cur_period_replcement$resource_occupancy > start_density) & (cur_period_replcement$resource_occupancy <= end_density)),]
    #print(paste("cur_competition:", end_density, ". number of replacements:", nrow(cur_period_cur_cd_replacement)))
    cur_period_cur_cd_replacement$n <- 1
    cur_period_cur_cd_replacement <- cur_period_cur_cd_replacement[order(cur_period_cur_cd_replacement$Actor_cow, cur_period_cur_cd_replacement$Reactor_cow),]
    
    # get the frequency of interactions between all dyads (A->B and B->A are considered as 2 different dyads)
    all_dyad_summary <- aggregate(cur_period_cur_cd_replacement$n, by = list(cur_period_cur_cd_replacement$Actor_cow, cur_period_cur_cd_replacement$Reactor_cow), FUN = sum)
    colnames(all_dyad_summary) <- c("Actor_cow", "Reactor_cow", "frequency")
    all_dyad_summary <- all_dyad_summary[order(all_dyad_summary$Actor_cow, all_dyad_summary$Reactor_cow),]
    
    # dyads can go 2 ways, give each dyad an unique dyad ID
    all_dyad_summary$dyadID <- 0
    for (y in 1:nrow(all_dyad_summary)) {
      bigger_id <- max(all_dyad_summary$Actor_cow[y], all_dyad_summary$Reactor_cow[y])
      smaller_id <- min(all_dyad_summary$Actor_cow[y], all_dyad_summary$Reactor_cow[y])
      unique_id <- paste(bigger_id, smaller_id, sep = "-")
      
      all_dyad_summary$dyadID[y] <- unique_id
    }
    
    # get the frequency of interactions between all unique dyads (A->B and B->A are considered 1 unique dyad)
    unique_dyad_summary <- aggregate(all_dyad_summary$frequency, by = list(all_dyad_summary$dyadID), FUN = sum)
    colnames(unique_dyad_summary) <-  c("dyadID", "total_frequency")
    
    # attach the total number of interactions between all unique dyads into the all dyad summary list
    all_dyad_summary2 <- merge(all_dyad_summary, unique_dyad_summary)
    all_dyad_summary2$directionality <- all_dyad_summary2$frequency/all_dyad_summary2$total_frequency
    
    # summarize direactionality of each unique dyad
    unique_dyad_direction <- aggregate(all_dyad_summary2$directionality, by = list(all_dyad_summary2$dyadID), FUN = max)
    colnames(unique_dyad_direction) <- c("dyadID", "directionality")
    unique_dyad_direction$start_density <- start_density
    unique_dyad_direction$end_density <- end_density
    unique_dyad_direction$resource_occupancy <- unique_dyad_direction$end_density
    unique_dyad_direction <- merge(unique_dyad_direction, unique_dyad_summary)
    
    # calculate percentage of unkown dyads
    percent_unkown <- 1- (nrow(unique_dyad_direction)/total_dyad_possible_num)
    temp_sum <- data.frame(start_density, end_density, percent_unkown)
    
    
    # generate master datasheet to store all results
    if (k ==1) {
      master_unique_dyad_direction <- unique_dyad_direction
      master_directionality_summary <- temp_sum
    } else {
      master_unique_dyad_direction <- rbind(master_unique_dyad_direction, unique_dyad_direction)
      master_directionality_summary <- rbind(master_directionality_summary, temp_sum)
    }
    
    k = k + group_by
  }
  
  master_dyad_analysis <- list()
  master_dyad_analysis[[1]] <- master_unique_dyad_direction
  master_dyad_analysis[[2]] <- master_directionality_summary
  
  return(master_dyad_analysis)
}


#' Plot Percentage of Unknown Dyads by Feeder Occupancy
#'
#' This function visualizes the percentage of unknown dyads as a function 
#' of feeder occupancy using a scatter plot and a linear regression line.
#'
#' @param master_directionality A dataframe containing the percentage of unknown dyads and feeder occupancy data.
#' @param output_dir A string specifying the directory where the plot should be saved.
#' 
#' @return Invisible NULL. The function saves a PNG plot in the specified directory.
plot_unknown <- function(master_directionality, output_dir) {
   
  # this is calculating the percentage of two-way dyads among all observed dyads
  # the ggplot dimension set to be the same as the SD of Elo by CD
  unknown <- ggplot(master_directionality, aes(x=end_density, 
                                                        y = percent_unkown)) + 
    geom_point(aes(y = percent_unkown), size = 10, color = "royal blue") +
    geom_smooth(method = "lm", se = FALSE, size= 2, color = "midnight blue") +
    labs(y= "Percentage of Unknown Dyads", 
         x = "Feeder Occupancy") +
    theme_classic() +
    theme(text = element_text(size = 55), axis.text.x = element_text(size = 50)) +
    scale_y_continuous(expand=expansion(mult = c(0, .1)), limits = c(0.2, 0.8))
  
  ggsave(here("graphs/unknown_byCD_long.png"), plot = unknown, width = 15, height = 13, limitsize = FALSE)

}


