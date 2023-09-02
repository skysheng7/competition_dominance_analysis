summarize_data <- function(data_frame, type = "Feeding") {
  # Ensure type is either "Feeding" or "Drinking"
  if(!type %in% c("Feeding", "Drinking")) {
    stop("The type should be either 'Feeding' or 'Drinking'.")
  }
  
  # Intake
  intake <- aggregate(data_frame[, "Intake"], list(data_frame$date, data_frame$Cow), sum)
  colnames(intake) <- c("date", "Cow", paste0(type, "_Intake(kg)"))
  
  # Duration
  duration <- aggregate(data_frame[, "Duration"], list(data_frame$date, data_frame$Cow), sum)
  colnames(duration) <- c("date", "Cow", paste0(type, "_Duration(s)"))
  
  # Visits
  visits <- count(data_frame, vars = c("date", "Cow"))
  colnames(visits) <- c("date", "Cow", paste0(type, "_Visits"))
  
  # Return a list of the three summary data.frames
  return(list(intake = intake, 
              duration = duration, 
              visits = visits))
}


