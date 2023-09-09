#' Group Density Levels into Custom Buckets
#'
#' This function groups density levels from a specified column into custom buckets 
#' based on a sequence of breaks. It then assigns the highest value in each bucket 
#' to the new column `feeder_occupancy_grouped`.
#'
#' @param df A dataframe containing the data to be grouped.
#' @param density_column A string specifying the name of the column containing density levels.
#' 
#' @return A dataframe with an additional column `feeder_occupancy_grouped` containing the grouped density levels.
group_density_buckets <- function(df, density_column) {
  # Define the custom sequence of breaks based on unique values
  breaks <- c(0, unique(df[[density_column]])[seq(0, length(unique(df[[density_column]])), 5)])
  
  # Group density levels into custom buckets
  df$feeder_occupancy_grouped <- cut(df[[density_column]], 
                                     breaks = breaks, 
                                     include.lowest = TRUE)
  
  # Find the highest value in each bucket
  df$feeder_occupancy_grouped <- sapply(levels(df$feeder_occupancy_grouped), function(x) {
    interval <- as.numeric(unlist(strsplit(gsub("\\(|\\]|\\[|\\)", "", x), ",")))
    return(max(interval))
  })[df$feeder_occupancy_grouped]
  
  return(df)
}

#' Find Dyads with >=2 Interactions in All Levels
#'
#' This function identifies dyads that have at least 2 interactions and are present 
#' in all of 5 grouped feeder occupancy levels
#'
#' @param data A dataframe containing the dyad data.
#' @param dyad_id_col A string specifying the name of the column containing dyad IDs.
#' @param occupancy_col A string specifying the name of the column containing occupancy levels.
#' 
#' @return A vector containing dyad IDs that are present in all unique levels of the occupancy column.
find_dyads_in_all_levels_mt2 <- function(data, dyad_id_col, occupancy_col) {
  data <- data[which(data$total_interactions>=2),]
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


#' Calculate Change in Winning Percentage per Dyad
#'
#' This function computes the change in winning percentage (`win_pct`) for each unique dyad 
#' as the feeder occupancy increases. The change is calculated relative to the winning 
#' percentage at the lowest feeder occupancy.
#'
#' @param df A dataframe containing the dyad data.
#' @param dyad_id_col A string specifying the name of the column containing dyad IDs.
#' @param occupancy_col A string specifying the name of the column containing occupancy levels.
#' @param win_pct_col A string specifying the name of the column containing winning percentages.
#' 
#' @return A dataframe with columns for the dyad ID, occupancy level, winning percentage, 
#'         change in winning percentage, and absolute change in winning percentage.
calculate_win_pct_change_per_dyad <- function(df, dyad_id_col, occupancy_col, win_pct_col) {
  # Get the unique dyad_ids
  dyad_ids <- unique(df[[dyad_id_col]])
  
  # Initialize a list to store the results
  results <- list()
  
  # Loop over the dyad_ids
  for(dyad_id in dyad_ids) {
    # Get the subset of data for the current dyad_id
    dyad_df <- df[df[[dyad_id_col]] == dyad_id, ]
    
    # Sort the dyad_df by feeder_occupancy_grouped
    dyad_df <- dyad_df[order(dyad_df[[occupancy_col]]), ]
    
    # Get the win_pct at the lowest feeder_occupancy_grouped
    base_win_pct <- dyad_df[[win_pct_col]][1]
    
    # Calculate the change in win_pct
    dyad_df$win_pct_change <- dyad_df[[win_pct_col]] - base_win_pct
    
    # Calculate the absolute change in win_pct
    dyad_df$win_pct_abs_change <- abs(dyad_df$win_pct_change)
    
    # Add the result to the list
    results[[dyad_id]] <- dyad_df
  }
  
  # Bind all the data frames in the list into a single data frame
  result_df <- do.call(rbind, results)
  
  return(result_df)
}


#' Plot Positive Changes in Winning Percentage using Violin and Box Plots
#'
#' @param win_pct_changes2_pos A dataframe containing positive changes in winning percentages.
positive_win_pct_change_violin_boxplot <- function(win_pct_changes2_pos) {
  
  # Define a color vector
  color_vector <- viridis::viridis(length(unique(win_pct_changes2_pos$feeder_occupancy_grouped)), direction = -1)
  
  # Define labels
  labels = c("(0.27, 0.43]", "(0.43, 0.6]", "(0.6, 0.77]", "(0.77, 1]")
  
  violin_boxplot <- ggplot(win_pct_changes2_pos, aes(x = as.factor(feeder_occupancy_grouped), y = win_pct_change, fill = as.factor(feeder_occupancy_grouped))) +
    geom_violin(lwd = 1.5, color = NA) +
    scale_fill_viridis_d(name = "Feeder \nOccupancy", direction = -1, guide = "none") +
    geom_boxplot(width = 0.1, fill = "white", lwd = 1.5, outlier.shape = 19, outlier.size = 6, outlier.fill = "black") +
    labs(x = "Feeder Occupancy", y = "Positive Changes in \nPercentage of Winning", fill = "Feeder Occupancy") +
    theme_classic() +
    #theme(text = element_text(size = 55), axis.text.x = element_text(size = 40, color = color_vector)) +
    theme(text = element_text(size = 55), axis.text.x = element_text(size = 40)) +
    scale_y_continuous(expand = expansion(mult = c(0, .1)), limits = c(0, 1)) +
    scale_x_discrete(labels = labels)
  
  file_name = here("graphs/positive_win_pct_change_violin_boxplot.png")
  ggsave(file_name, plot = violin_boxplot, width = 15, height = 13, limitsize = FALSE)
  
}

#' Plot Negative Changes in Winning Percentage using Violin and Box Plots
#'
#' @param win_pct_changes2_neg A dataframe containing negative changes in winning percentages.
negative_win_pct_change_violin_boxplot <- function(win_pct_changes2_neg) {
  
  # Define a color vector
  color_vector <- viridis::viridis(length(unique(win_pct_changes2_neg$feeder_occupancy_grouped)), direction = -1)
  
  # Define labels
  labels = c("(0.27, 0.43]", "(0.43, 0.6]", "(0.6, 0.77]", "(0.77, 1]")
  
  violin_boxplot <- ggplot(win_pct_changes2_neg, aes(x = as.factor(feeder_occupancy_grouped), y = win_pct_change, fill = as.factor(feeder_occupancy_grouped))) +
    geom_violin(lwd = 1.5, color = NA) +
    scale_fill_viridis_d(name = "Feeder \nOccupancy", direction = -1, guide = "none") +
    geom_boxplot(width = 0.1, fill = "white", lwd = 1.5, outlier.shape = 19, outlier.size = 6, outlier.fill = "black") +
    labs(x = "Feeder Occupancy", y = "Negative Changes in \nPercentage of Winning", fill = "Feeder Occupancy") +
    theme_classic() +
    #theme(text = element_text(size = 55), axis.text.x = element_text(size = 40, color = color_vector)) +
    theme(text = element_text(size = 55), axis.text.x = element_text(size = 40)) +
    scale_y_continuous(expand = expansion(mult = c(0, .1)), limits = c(-1, 0)) +
    scale_x_discrete(labels = labels)
  
  file_name = here("graphs/negative_win_pct_change_violin_boxplot.png")
  ggsave(file_name, plot = violin_boxplot, width = 15, height = 13, limitsize = FALSE)
  
}