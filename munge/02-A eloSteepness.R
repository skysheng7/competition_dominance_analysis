################################################################################
## Group Level Analysis: Steepness under different legels of feeder occupancy ##
################################################################################
# mark down regrouping days
regrouping <- identify_regoup(all.comb2, warning_days)

# process the raw datasheet containing cleaned feed & drinking data, add start and end hour
master_comb <- feed_extra_processing(master_comb)

# prepare replacement data
total_bin <- max_feed_bin - min_feed_bin + 1
master_feed_replacement_all$total_bin <- total_bin

# load synchronicity matrix
load(here::here(paste0("data/results/", "which cows are present each second for feed.rda")))
load(here::here(paste0("data/results/", "which bins are occupied each second for feed.rda")))
load(here::here(paste0("data/results/", "how much feed left each bin.rda")))
cows_present_each_second_list <- feeding_synch_master_cow
bins_occupied_for_feed_list <- feeding_synch_master_bin
feed_each_bin_list <- feeding_synch_master_feed

# process the feed replacement data 
master_feed_replacement_all <- replace_processing(master_feed_replacement_all, cows_present_each_second_list, bins_occupied_for_feed_list, feed_each_bin_list, method_type)
save(master_feed_replacement_all, file = here("data/results/master_feed_replacement_all_with_feeder_occupancy.rda"))

# plot histogram
output_dir <- here("graphs/")
dir_check_create(output_dir) # check if that output_dir exists, and create one if it does not exist
replac_num_each_bucket <- plot_replace_hist(master_feed_replacement_all, total_bin, output_dir)

# calculate the percentage of replacement occured per hour
replacement_per_hour2 <- calculate_replacement_per_hour(master_feed_replacement_all)

# calculate the average CD per hour
cd_per_hour <- aggregate(master_feed_replacement_all$resource_occupancy, by = list(master_feed_replacement_all$hour), FUN = mean)
colnames(cd_per_hour) <- c("hour", "resource_occupancy")

# calculate how many levels of Feeder Occupancy  is needed and the sample size for each level
bucket_num <- total_bin
total_cow_num <- length(unique(master_comb$Cow))
min_replacement_num <- 10 * total_cow_num
group_size <- 48
res_occupancy_seq <- c(0, (seq(4, 27, by = 1))/total_bin, 1)
res_occupancy_seq <- round(res_occupancy_seq, digits = 5)
sample_size <- sample_size_per_bucket(res_occupancy_seq, replac_num_each_bucket) # get the number of replacements in the lowest bucket
# if the lowest bucket has more than 10 * cowNumber replacements, then we are settled with this many levels of Feeder Occupancy  and sample size
if (sample_size >= min_replacement_num) {
  print(paste((length(res_occupancy_seq)-1), " levels of Feeder Occupancy  were used in the end", sep = ""))
} else {
  print("Did not meet minimum number of replacements required for Elo calculation at each level. Please redefine your sequence of Feeder Occupancy.")
}

# calculate elo under different Feeder Occupancy 
elo_steepness_competition(master_feed_replacement_all, master_comb, res_occupancy_seq, sample_size, output_dir)

# plot the steepness of elo under different Feeder Occupancy
master_steepness2 <- master_steepness
elo_steepness_plot(master_steepness, output_dir)

# fit a linear model for Elo Steepness X Feeder Occupancy
steepness_lm <- lm(master_steepness$steepness_mean ~ master_steepness$resource_occupancy)
steepness_lm_summary <- summary(steepness_lm)


################################################################################
################# Dyad Level Analysis: percentage of unkown dyads ##############
################### control for same number of replacements ####################
################################################################################
total_dyad_possible_num <- total_dyad_long_term(all.comb2)
group_by <- 1
master_dyad_analysis_10mon_control <- dyad_relationship_long_term(replacement_sampled_master, res_occupancy_seq, group_by, total_dyad_possible_num)
master_unique_dyad_direction_10mon_control <- master_dyad_analysis_10mon_control[[1]]
dyads_unknown <- master_dyad_analysis_10mon_control[[2]]
plot_unknown(dyads_unknown, output_dir) 

unknown_lm <- lm(percent_unkown ~ end_density, data = dyads_unknown)
unknown_lm_summary <- summary(unknown_lm)


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


