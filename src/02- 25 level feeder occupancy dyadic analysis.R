################################################################################
################# Dyad Level Analysis: percentage of unkown dyads ##############
################### control for same number of replacements ####################
################################################################################
total_dyad_possible_num <- total_dyad_long_term(all.comb2)
group_by <- 1
master_dyad_analysis_10mon_control <- dyad_relationship_long_term(replacement_sampled_master, res_occupancy_seq, group_by, total_dyad_possible_num)
master_unique_dyad_direction_10mon_control <- master_dyad_analysis_10mon_control[[1]]
dyads_unknown <- master_dyad_analysis_10mon_control[[2]]

plot_unknown(dyads_unknown, here("graphs/")) 

# linear model fit
unknown_lm <- lm(percent_unkown ~ end_density, data = dyads_unknown)
unknown_lm_summary <- summary(unknown_lm)

################################################################################
################# Dyad Level Analysis: percentage of unique dyads ##############
################### control for same number of replacements ####################
################################################################################
repl_master <- replacement_sampled_master[, c("Actor_cow", "Reactor_cow", "end_density")]
colnames(repl_master) <- c("winner", "loser", "feeder_occupancy")

interactions_by_dyad <- calculate_interactions_by_dyad(repl_master, "feeder_occupancy")
# find dyads that show up in all levels of feeder occupancy
dyads_in_all_levels <- find_dyads_in_all_levels(interactions_by_dyad, "dyad_id", "feeder_occupancy")

# find dyads that only show up in certain levels
results <- find_dyads_in_single_level(interactions_by_dyad, "dyad_id", "feeder_occupancy")
single_level_dyads_df <- results$single_level_dyads
single_level_dyads_count_df <- results$single_level_dyads_count
colnames(single_level_dyads_count_df) <- c("feeder_occupancy", "unique_dyad_num")

total_dyad <- calculate_total_dyads(interactions_by_dyad)
single_level_dyads_count_df2 <- merge(single_level_dyads_count_df, total_dyad)
single_level_dyads_count_df2$unique_dyad_pct <- single_level_dyads_count_df2$unique_dyad_num/single_level_dyads_count_df2$total_dyad

# linear model fit for unique dyad per feeder occupancy level
single_level_dyads_lm <- lm(unique_dyad_pct ~ feeder_occupancy, data = single_level_dyads_count_df2)
single_level_dyads_lm_summary <- summary(single_level_dyads_lm)

################################################################################
########## Dyad Level Analysis: percentage of two way dyads among dyads ########
######################## with >= 2 interactions ################################
################### control for same number of replacements ####################
################################################################################
two_way_dyad_perct <- two_way_dyad_pct_calculation(interactions_by_dyad)

# plot the changes of percentage of 2-way dyads (among dyads with >=2 interactions) 
# as feeder occupancy increases
two_way_pct_plot(two_way_dyad_perct)

# linear model fit for two-way dyad per feeder occupancy level
two_way_dyads_lm <- lm(`2way_pct` ~ feeder_occupancy, data = two_way_dyad_perct)
two_way__dyads_lm_summary <- summary(two_way_dyads_lm)


