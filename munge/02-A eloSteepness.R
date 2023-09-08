################################################################################
## Group Level Analysis: Steepness under different levels of feeder occupancy ##
################################################################################
# mark down regrouping days
regrouping <- identify_regoup(all.comb2, warning_days)

# process the raw datasheet containing cleaned feed & drinking data, add start and end hour
master_comb <- feed_extra_processing(master_comb)

# prepare replacement data
total_bin <- max_feed_bin - min_feed_bin + 1
master_feed_replacement_all_with_feeder_occupancy <- master_feed_replacement_all
master_feed_replacement_all_with_feeder_occupancy$total_bin <- total_bin

# load synchronicity matrix
load(here::here(paste0("data/results/", "which cows are present each second for feed.rda")))
load(here::here(paste0("data/results/", "which bins are occupied each second for feed.rda")))
load(here::here(paste0("data/results/", "how much feed left each bin.rda")))
cows_present_each_second_list <- feeding_synch_master_cow
bins_occupied_for_feed_list <- feeding_synch_master_bin
feed_each_bin_list <- feeding_synch_master_feed

# process the feed replacement data 
master_feed_replacement_all_with_feeder_occupancy <- replace_processing(master_feed_replacement_all_with_feeder_occupancy, cows_present_each_second_list, bins_occupied_for_feed_list, feed_each_bin_list, method_type)

# plot histogram
output_dir <- here("graphs/")
dir_check_create(output_dir) # check if that output_dir exists, and create one if it does not exist
replac_num_each_bucket <- plot_replace_hist(master_feed_replacement_all_with_feeder_occupancy, total_bin)

# calculate the percentage of replacement occured per hour
replacement_per_hour2 <- calculate_replacement_per_hour(master_feed_replacement_all_with_feeder_occupancy)
save(replacement_per_hour2, file = here("data/results/replacement_per_hour.rda"))

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

cache("res_occupancy_seq")
cache("sample_size")

# calculate elo under different Feeder Occupancy 
elo_steepness_competition(master_feed_replacement_all_with_feeder_occupancy, master_comb, res_occupancy_seq, sample_size)

