library('ProjectTemplate')
load.project()

################################################################################
############### Steepness changes as feeder occupancy increases ################
################################################################################
# plot the steepness of elo under different Feeder Occupancy
master_steepness2 <- master_steepness
elo_steepness_plot(master_steepness)

# fit a linear model for Elo Steepness X Feeder Occupancy
steepness_lm <- lm(master_steepness$steepness_mean ~ master_steepness$resource_occupancy)
steepness_lm_summary <- summary(steepness_lm)

