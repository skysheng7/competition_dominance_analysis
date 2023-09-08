################################################################################
################# Dyad Level Analysis: percentage of unkown dyads ##############
################### control for same number of replacements ####################
################################################################################
total_dyad_possible_num <- total_dyad_long_term(all.comb2)
group_by <- 1
master_dyad_analysis_10mon_control <- dyad_relationship_long_term(replacement_sampled_master, res_occupancy_seq, group_by, total_dyad_possible_num)
master_unique_dyad_direction_10mon_control <- master_dyad_analysis_10mon_control[[1]]
dyads_unknown <- master_dyad_analysis_10mon_control[[2]]

cache("dyads_unknown")

################################################################################
############### Percentage of Aberrant Replacements ############################
################################################################################
rda_dir <- here("data/results/")

master_aberrant_track <- aberrant_replacement(rda_dir)
master_aberrant_track <- master_aberrant_track[order(master_aberrant_track$cur_cd),]
# fit a linear model
aberrant_lm <- lm(master_aberrant_track$aberrant_replacement_percent ~ master_aberrant_track$cur_cd)
aberrant_lm_summary <- summary(aberrant_lm)
plot_aberrant_by_CD(master_aberrant_track, output_dir)


