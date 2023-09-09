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