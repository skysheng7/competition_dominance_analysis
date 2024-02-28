# Convert end_density to a factor for discrete x-axis levels
replacement_sampled <- replacement_sampled_master
replacement_sampled$end_density <- as.factor(replacement_sampled$end_density)

# Plotting
ggplot(replacement_sampled, aes(x = end_density, y = Bout_interval)) + 
  geom_boxplot() +
  labs(x = "Feeder Occupancy", y = "Replacement Bout Interval") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # This helps if labels overlap

# Fit a linear model
bout_interval_changes_lm <- lm(Bout_interval ~ end_density, data = replacement_sampled_master)
# Summary of the linear model
summary(bout_interval_changes_lm)
