################################################################################
################# Dyad Level Analysis: percentage of unkown dyads ##############
################### control for same number of replacements ####################
################################################################################

plot_unknown(dyads_unknown, output_dir) 

unknown_lm <- lm(percent_unkown ~ end_density, data = dyads_unknown)
unknown_lm_summary <- summary(unknown_lm)

