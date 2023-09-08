################################################################################
################# Dyad Level Analysis: percentage of unkown dyads ##############
################### control for same number of replacements ####################
################################################################################

plot_unknown(dyads_unknown, output_dir) 

unknown_lm <- lm(percent_unkown ~ end_density, data = dyads_unknown)
unknown_lm_summary <- summary(unknown_lm)

################################################################################
################# Dyad Level Analysis: percentage of two-way dyads #############
################### control for same number of replacements ####################
################################################################################
repl_master <- replacement_sampled_master[, c("Actor_cow", "Reactor_cow", "end_density")]
colnames(repl_master) <- c("winner", "loser", "feeder_occupancy")

interactions_by_dyad <- calculate_interactions_by_dyad(repl_master)
# find dyads that show up in all levels of feeder occupancy
dyads_in_all_levels <- find_dyads_in_all_levels(interactions_by_dyad, "dyad_id", "feeder_occupancy")

# find dyads that only show up in certain levels
results <- find_dyads_in_single_level(interactions_by_dyad, "dyad_id", "feeder_occupancy")
single_level_dyads_df <- results$single_level_dyads
single_level_dyads_count_df <- results$single_level_dyads_count
colnames(single_level_dyads_count_df) <- c("feeder_occupancy", "unique_dyad_num")

