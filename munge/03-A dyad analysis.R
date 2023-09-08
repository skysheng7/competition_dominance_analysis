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


