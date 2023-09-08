################################################################################
############################# unknown dyads ####################################
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

################################################################################
############################## unique dydds ####################################
################################################################################

#' This function converts a given contingency table into a dataframe and 
#' adds a new column representing the occupancy level.
#'
#' @param contingency_table A contingency table to be converted.
#' @param occupancy_level A numeric value representing the occupancy level.
#' 
#' @return A dataframe with columns: winner, loser, interactions, and feeder_occupancy.
contingency_to_dataframe <- function(contingency_table, occupancy_level) {
  temp_df <- as.data.frame(as.table(contingency_table))
  colnames(temp_df) <- c("winner", "loser", "interactions")
  temp_df$feeder_occupancy <- occupancy_level
  temp_df
}

#' Find Dyads Present in All Levels
#'
#' This function identifies dyads that appear in all unique levels of a given occupancy column.
#'
#' @param data A dataframe containing the dyad data.
#' @param dyad_id_col A string representing the column name of the dyad ID.
#' @param occupancy_col A string representing the column name of the feeder occupancy level.
#' 
#' @return A vector containing dyad IDs that appear in all unique levels of the occupancy column.
find_dyads_in_all_levels <- function(data, dyad_id_col, occupancy_col) {
  # Group the data by dyad_id and feeder_occupancy_grouped
  grouped_data <- aggregate(data[[occupancy_col]], by = list(data[[dyad_id_col]], data[[occupancy_col]]), FUN = length)
  
  # Count the number of unique levels of feeder_occupancy_grouped for each dyad_id
  dyad_counts <- aggregate(grouped_data$x, by = list(grouped_data$Group.1), FUN = length)
  
  # Find the total number of unique levels of feeder_occupancy_grouped
  total_levels <- length(unique(data[[occupancy_col]]))
  
  # Filter the dyad_id that have counts equal to the total number of unique levels of feeder_occupancy_grouped
  dyads_in_all_levels <- dyad_counts[dyad_counts$x == total_levels, "Group.1"]
  
  return(dyads_in_all_levels)
}

#' Calculate Total Interactions Per Dyad
#'
#' This function calculates the total number of interactions for each dyad.
#' It first creates a unique dyad ID by combining the winner and loser columns.
#' It then filters out rows where the winner and loser are the same and calculates
#' the total number of interactions for each unique dyad.
#'
#' @param process_df A dataframe containing the dyad data with columns "winner", "loser", and "interactions".
#' 
#' @return A dataframe with the total number of interactions for each dyad and the winning percentage.
total_interaction_per_dyad <- function(process_df){
  # Create a combined dyad_id
  process_df$dyad_id <- apply(process_df[, c("winner", "loser")], 1, function(x) paste(sort(as.integer(x)), collapse = "-"))
  # remove when winner and loser are the same, also remove the dyads that have 0 interactions
  process_df2 <- process_df[as.character(process_df$winner) != as.character(process_df$loser), ]
  
  
  # calculate the total number of interaction per unique dyad A>B and A<B are the same dyad
  interact_per_dyad <- aggregate(process_df2$interactions, by = list(process_df2$dyad_id), FUN = sum)
  colnames(interact_per_dyad) <- c("dyad_id", "total_interactions")
  process_df3 <-merge(process_df2, interact_per_dyad)
  process_df3 <- process_df3[which(process_df3$total_interactions >0),]
  process_df3$win_pct <- process_df3$interactions/process_df3$total_interactions
  process_df3 <- process_df3[order(process_df3$dyad_id),]
  
  return(process_df3)
}


#' Process Dyads to Set Dominant Winner
#'
#' This function processes a dataframe to ensure that for each dyad, there's only one record 
#' where the cow that wins more is set as the winner. If there's a tie in the number of wins, 
#' the cow with the larger ID is set as the winner.
#' 
#' for each dyad, they have an unique dyad_id.
#' as I need to record the winner and loser for each dyad, I set the winner cow to be
#' the cow that wins more over the other, when this dyad appear for the first time in a feeder occupancy level
#'
#' @param process_df3 A dataframe containing the dyad data with columns "winner", "loser", "win_pct", and "dyad_id".
#' 
#' @return A dataframe with processed dyads where each dyad has only one record with the dominant winner set.

low_fo_dyad_set <- function(process_df3) {
  # now there are 2 record for each dyad, because A>B and A<B are in 2 seperate rows.
  # For each dyad, only keep 1 record, the record where the cow that wins more is placed on the winner
  process_df4 <- process_df3[which(process_df3$win_pct >=0.5),]
  process_df4_no_tie <- process_df4[which(process_df4$win_pct > 0.5),]
  
  #for dyads where 2 individuals wins the same amount, assign the winner to be the cow with larger cow ID
  process_df4_tie <- process_df4[which(process_df4$win_pct == 0.5),]
  process_df4_tie$winner <- NULL
  process_df4_tie$loser <- NULL
  process_df4_tie <- unique(process_df4_tie)
  split_ids <- strsplit(process_df4_tie$dyad_id, "-") # Split the dyad_id column on the hyphen
  process_df4_tie$winner <- sapply(split_ids, function(x) x[1])  # Extract the winner (first cow ID before the hyphen)
  process_df4_tie$loser <- sapply(split_ids, function(x) x[2])  # Extract the loser (second cow ID after the hyphen)
  process_df4_tie <- process_df4_tie[, colnames(process_df4_no_tie)]
  
  process_df5 <- rbind(process_df4_no_tie, process_df4_tie)
  
  return(process_df5)
}

#' Process Dyads Based on Previous Appearances
#'
#' This function processes a dataframe to determine the sequence of winners and losers for dyads 
#' based on their previous appearances in the lowest level of feeder occupancy. If a dyad hasn't 
#' appeared in previous levels, it uses the method from the `low_fo_dyad_set` function to determine the sequence.
#'
#' @param prog_df A dataframe containing the dyad data with columns "dyad_id", "winner", and "loser".
#' @param interactions_by_dyad A dataframe containing previous interactions by dyad.
#' 
#' @return A dataframe with processed dyads based on their previous appearances.
other_fo_dyad_set <- function(prog_df, interactions_by_dyad) {
  # for the dyads that have showed up in previous levels of feeder occupancy
  # keep the sequence of who is the winner and who is the loser
  dyad_seq <- unique(interactions_by_dyad[, c("dyad_id", "winner", "loser")])
  dyad_showed <- prog_df[which(prog_df$dyad_id %in% dyad_seq$dyad_id),]
  dyad_showed_processed <- merge(prog_df, dyad_seq)
  
  # for those did not show up in previous levels of feeder occupancy
  # record the dyad using the same method as the loest feeder occupancy level
  dyad_not_showed <- prog_df[which(!(prog_df$dyad_id %in% dyad_seq$dyad_id)),]
  if (nrow(dyad_not_showed) > 0) { # if there are new dyad show up
    dyad_not_showed_processed <- low_fo_dyad_set(dyad_not_showed)
    
    # order column names
    dyad_showed_processed <- dyad_showed_processed[, colnames(dyad_not_showed_processed)]
    
    prog_df_processed <- rbind(dyad_showed_processed, dyad_not_showed_processed)
  } else {
    prog_df_processed <- dyad_showed_processed
  }
  
  
  return(prog_df_processed)
}


#' Find Dyads Present in Only One Level of Feeder Occupancy not the other levels
#'
#' This function identifies dyads that only appear in one specific level of feeder occupancy 
#' and not in other levels. It returns these dyads along with the specific level they appear in, 
#' as well as a count of how many such dyads are present in each level.
#'
#' @param data A dataframe containing the dyad data.
#' @param dyad_id_col The column name in the dataframe that represents the dyad ID.
#' @param occupancy_col The column name in the dataframe that represents the feeder occupancy level.
#' 
#' @return A list containing two dataframes: 
#'   - single_level_dyads: A dataframe with dyads that only appear in one specific level of feeder occupancy.
#'   - single_level_dyads_count: A dataframe with a count of how many such dyads are present in each level.
find_dyads_in_single_level <- function(data, dyad_id_col, occupancy_col) {
  # Group the data by dyad_id and feeder_occupancy_grouped
  grouped_data <- aggregate(data[[occupancy_col]], by = list(data[[dyad_id_col]], data[[occupancy_col]]), FUN = length)
  
  # Count the number of unique levels of feeder_occupancy_grouped for each dyad_id
  dyad_counts <- aggregate(grouped_data$x, by = list(grouped_data$Group.1), FUN = length)
  
  # Filter the dyad_id that have counts equal to 1
  single_level_dyads <- dyad_counts[dyad_counts$x == 1, "Group.1"]
  
  # Create an empty dataframe to store results
  result_df <- data.frame(dyad_id = character(), feeder_occupancy_grouped = numeric())
  
  # Create an empty dataframe to store the count of single_level_dyads for each level
  count_df <- data.frame(feeder_occupancy_grouped = numeric(), count = integer())
  
  # Loop through each unique level of feeder_occupancy_grouped
  for (level in unique(data[[occupancy_col]])) {
    # Filter the dyad_id that only show up in the current level
    dyads_in_current_level <- grouped_data[grouped_data$Group.1 %in% single_level_dyads & grouped_data$Group.2 == level, "Group.1"]
    
    # Create a dataframe with the filtered dyad_id and their corresponding feeder_occupancy_grouped level
    current_level_df <- data.frame(dyad_id = dyads_in_current_level, feeder_occupancy_grouped = level)
    
    # Append the current level dataframe to the result dataframe
    result_df <- rbind(result_df, current_level_df)
    
    # Record the count of single_level_dyads for the current level
    count_df <- rbind(count_df, data.frame(feeder_occupancy_grouped = level, count = length(dyads_in_current_level)))
  }
  
  return(list(single_level_dyads = result_df, single_level_dyads_count = count_df))
}

#' Calculate replacements by Dyad at Different Feeder Occupancy Levels
#'
#' This function calculates the number of replacements that occurred per dyad 
#' at each of the 25 levels of feeder occupancy.
#'
#' @param repl_master A dataframe containing interaction data with columns 'feeder_occupancy', 'winner', and 'loser'.
#'
#' @return A dataframe containing interactions by dyad at different feeder occupancy levels.
calculate_interactions_by_dyad <- function(repl_master) {
  
  fed_occupancy_list <- unique(repl_master$feeder_occupancy)
  contingency_tables <- list()
  interactions_by_dyad <- data.frame()
  
  for (i in 1:length(fed_occupancy_list)) {
    # Subset data by feeder occupancy level
    occupancy_data <- subset(repl_master, feeder_occupancy == fed_occupancy_list[i])
    # Create contingency table for winner-loser pairs with the same unique values
    occupancy_dyad_table <- table(factor(occupancy_data$winner, levels = sort(unique(c(occupancy_data$winner, occupancy_data$loser)))),
                                  factor(occupancy_data$loser, levels = sort(unique(c(occupancy_data$winner, occupancy_data$loser)))))
    
    # Transform the contingency table into a dataframe
    temp_df <- contingency_to_dataframe(occupancy_dyad_table, fed_occupancy_list[i])
    
    # create unique dyad_id, and calculate total number of interactions/dyad, and wining percentage
    temp_df3 <- total_interaction_per_dyad(temp_df)
    
    # when it's the lowest level of feeder occupancy, for each dyad, only keep 1 record, 
    # the record where the cow that wins more is placed on the winner
    if (i == 1) {
      temp_df5 <- low_fo_dyad_set(temp_df3)
    } else {
      temp_df5 <- other_fo_dyad_set(temp_df3, interactions_by_dyad)
    }
    
    # Append merged dyads to the final dataframe
    interactions_by_dyad <- rbind(interactions_by_dyad, temp_df5)
  }
  
  interactions_by_dyad$feeder_occupancy <- round(interactions_by_dyad$feeder_occupancy, digits = 2)
  
  return(interactions_by_dyad)
}

#' Calculate Total Dyads for Each Level of Feeder Occupancy
#'
#' This function computes the total number of dyads for each unique level of feeder occupancy.
#'
#' @param interactions_by_dyad A dataframe containing interaction data for different dyads across various levels of feeder occupancy.
#' 
#' @return A dataframe with two columns: 
#'   - feeder_occupancy: The unique levels of feeder occupancy.
#'   - total_dyad: The total number of dyads for each level of feeder occupancy.
calculate_total_dyads <- function(interactions_by_dyad){
  temp = interactions_by_dyad
  temp$c = 1
  total_dyad <- aggregate(temp$c, by = list(temp$feeder_occupancy), FUN = sum)
  colnames(total_dyad) <- c("feeder_occupancy", "total_dyad")
  
  return(total_dyad)
}


#' Calculate Percentage of 2-Way Dyads for Dyads with 2 or More Interactions
#'
#' This function calculates the percentage of 2-way dyads for dyads with 2 or more interactions.
#' It filters the dyads based on the total number of interactions and then calculates the percentage 
#' of 2-way interactions for each level of feeder occupancy.
#'
#' @param interactions_by_dyad A dataframe containing interaction data for different dyads across various levels of feeder occupancy.
#' 
#' @return A dataframe with columns: 
#'   - feeder_occupancy: The unique levels of feeder occupancy.
#'   - dyads_mt2_interact: The total number of dyads with more than 2 interactions.
#'   - 2way_dyad: The total number of 2-way dyads.
#'   - 2way_pct: The percentage of 2-way dyads.
two_way_dyad_pct_calculation <- function(interactions_by_dyad) {
  mt_2_dyad <- interactions_by_dyad[which(interactions_by_dyad$total_interactions >=2),]
  mt_2_dyad_temp <- mt_2_dyad
  mt_2_dyad_temp$c = 1
  mt_2_dyad_total <- aggregate(mt_2_dyad_temp$c, by = list(mt_2_dyad_temp$feeder_occupancy), FUN = sum)
  colnames(mt_2_dyad_total) <- c("feeder_occupancy", "dyads_mt2_interact")
  mt_2_2way_dyad <- mt_2_dyad[which((abs(mt_2_dyad$win_pct) != 1 ) & (abs(mt_2_dyad$win_pct) != 0)),]
  mt_2_2way_dyad$c = 1
  mt_2_2way_dyad_total <- aggregate(mt_2_2way_dyad$c, by = list(mt_2_2way_dyad$feeder_occupancy), FUN = sum)
  colnames(mt_2_2way_dyad_total) <- c("feeder_occupancy", "2way_dyad")
  two_way_dyad_perct <- merge(mt_2_dyad_total, mt_2_2way_dyad_total)
  two_way_dyad_perct$`2way_pct` <- two_way_dyad_perct$`2way_dyad`/two_way_dyad_perct$dyads_mt2_interact
  
  return(two_way_dyad_perct)
}

#' Plot Percentage of Two-way Dyads by Feeder Occupancy
#'
#' This function creates a scatter plot to visualize the percentage of two-way dyads among dyads 
#' with 2 or more interactions across different levels of feeder occupancy.
#'
#' @param dyad_summary2 A dataframe containing the summary of dyads with columns 'feeder_occupancy' and '2way_pct'.
#' 
#' @return A ggplot object visualizing the percentage of two-way dyads by feeder occupancy.
#' 
two_way_pct_by_feeder_occupancy_plot <- function(dyad_summary2) {
  two_way_pct_plot <- ggplot(dyad_summary2, aes(x=feeder_occupancy, y = `2way_pct`)) + 
    geom_point(aes(y = `2way_pct`), size = 10, color = "royal blue") +
    geom_smooth(method = "lm", se = FALSE, size= 2, color = "midnight blue", fullrange = TRUE) +
    labs(y= "Percentage of Two-way Dyads", x = "Feeder Occupancy") +
    theme_classic() +
    theme(text = element_text(size = 55), axis.text.x = element_text(size = 50)) +
    scale_y_continuous(expand=expansion(mult = c(0, .1)), limits = c(0, 0.63))
  
  return(two_way_pct_plot)
}

#' Save Two-way Dyads Percentage Plot by Feeder Occupancy
#'
#' This function generates a scatter plot visualizing the percentage of two-way dyads among dyads 
#' with 2 or more interactions across different levels of feeder occupancy and saves it to a specified directory.
#'
#' @param dyad_summary2 A dataframe containing the summary of dyads with columns 'feeder_occupancy' and '2way_pct'.
#' @param output_dir A string specifying the directory where the plot should be saved.
two_way_pct_plot <- function(dyad_summary2) {
  two_way_pct_plot <- two_way_pct_by_feeder_occupancy_plot(dyad_summary2)
  file_name = here("graphs/2way_pct_by_feeder_occupancy.png")
  ggsave(file_name, plot = two_way_pct_plot, width = 15, height = 13, limitsize = FALSE)
}

