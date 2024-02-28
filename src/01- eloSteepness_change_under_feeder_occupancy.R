library('ProjectTemplate')
load.project()

################################################################################
############### Steepness changes as feeder occupancy increases ################
################################################################################
# plot the steepness of elo under different Feeder Occupancy
master_steepness2 <- master_steepness
master_steepness2$resource_occupancy <- master_steepness2$resource_occupancy * 100
elo_steepness_plot(master_steepness2)

# fit a linear model for Elo Steepness X Feeder Occupancy
steepness_lm <- lm(master_steepness2$steepness_mean ~ master_steepness2$resource_occupancy)
steepness_lm_summary <- summary(steepness_lm)


