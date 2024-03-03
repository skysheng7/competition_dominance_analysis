# Convert end_density to a factor for discrete x-axis levels
replacement_sampled <- replacement_sampled_master
replacement_sampled$end_density <- replacement_sampled$end_density * 100
replacement_sampled$end_density <- round(replacement_sampled$end_density, 2)
replacement_sampled$end_density <- as.factor(replacement_sampled$end_density)

# Plotting
ggplot(replacement_sampled, aes(x = end_density, y = Bout_interval)) + 
  geom_boxplot() +
  labs(x = "Feeder Occupancy", y = "Replacement Bout Interval") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 15), # Increases font size for x-axis labels and adjusts angle
        axis.text.y = element_text(size = 15), # Increases font size for y-axis labels
        axis.title = element_text(size = 16), # Increases font size for axis titles
        plot.title = element_text(size = 18)) # Increases font size for the plot title if you have one

# Fit a linear model
bout_interval_changes_lm <- lm(Bout_interval ~ end_density, data = replacement_sampled_master)
# Summary of the linear model
summary(bout_interval_changes_lm)
