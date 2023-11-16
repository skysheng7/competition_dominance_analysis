repl_master <- replacement_sampled_master[, c("Actor_cow", "Reactor_cow", "end_density")]
colnames(df = repl_master) <- c("winner", "loser", "feeder_occupancy")

repl_master_grouped <- group_density_buckets(repl_master, "feeder_occupancy")
interactions_by_dyad_grouped <- calculate_interactions_by_dyad(repl_master_grouped, "feeder_occupancy_grouped")

# find dyads that show up in all 5 levels of feeder occupancy
dyads_in_all_levels_grouped <- find_dyads_in_all_levels(interactions_by_dyad_grouped, "dyad_id", "feeder_occupancy_grouped")
interactions_by_dyad_same_across_all_levels_grouped <- interactions_by_dyad_grouped[which(interactions_by_dyad_grouped$dyad_id %in% dyads_in_all_levels_grouped),]
dyads_in_all_levels_grouped_num <- length(dyads_in_all_levels_grouped)


win_pct_changes <- calculate_win_pct_change_per_dyad(
  interactions_by_dyad_same_across_all_levels_grouped, 
  "dyad_id",
  "feeder_occupancy_grouped", 
  "win_pct"
)

# the changes in win pct is all relative to the lowest level of feeder occupancy after grouping (which is 0% - 27%)
win_pct_changes2 <- win_pct_changes[which(win_pct_changes$feeder_occupancy_grouped != 0.27),]
win_pct_changes2_0 <- win_pct_changes2[which(win_pct_changes2$win_pct_change ==0),]
win_pct_changes2_pos <- win_pct_changes2[which(win_pct_changes2$win_pct_change >0),]
win_pct_changes2_neg <- win_pct_changes2[which(win_pct_changes2$win_pct_change <0),]

# plot dyads with positive and negative changes
positive_win_pct_change_violin_boxplot(win_pct_changes2_pos)
negative_win_pct_change_violin_boxplot(win_pct_changes2_neg) 


# Fit a mixed-effects model
control <- lmerControl(optimizer = "bobyqa")
win_pct_changes_pos <- lmerTest::lmer(win_pct_change ~ feeder_occupancy_grouped + (feeder_occupancy_grouped | dyad_id), data = win_pct_changes2_pos, control = control)
summary(win_pct_changes_pos)
win_pct_changes_neg <- lmerTest::lmer(win_pct_change ~ feeder_occupancy_grouped + (feeder_occupancy_grouped | dyad_id), data = win_pct_changes2_neg, control = control)
summary(win_pct_changes_neg)

# calculate the percentage of dyads with 0 change in win_pct across all levels
total_same_dyad <- length(unique(win_pct_changes2$dyad_id))
grouped_df <- dplyr::group_by(win_pct_changes2_0, feeder_occupancy_grouped)
unique_dyad_counts <- dplyr::summarise(grouped_df, n_unique_dyads = dplyr::n_distinct(dyad_id))
colnames(unique_dyad_counts) <- c("feeder_occupancy_grouped", "dyads_0_change")
unique_dyad_counts$dyads_0_change_pct <- unique_dyad_counts$dyads_0_change/total_same_dyad

# calculate the percentage of dyads with negative changes in win pct in win_pct across all levels
total_same_dyad <- length(unique(win_pct_changes2$dyad_id))
grouped_df_neg <- dplyr::group_by(win_pct_changes2_neg, feeder_occupancy_grouped)
unique_dyad_counts_neg <- dplyr::summarise(grouped_df_neg, n_unique_dyads = dplyr::n_distinct(dyad_id))
colnames(unique_dyad_counts_neg) <- c("feeder_occupancy_grouped", "dyads_neg_change")
unique_dyad_counts_neg$dyads_neg_change_pct <- unique_dyad_counts_neg$dyads_neg_change / total_same_dyad

# calculate the percentage of dyads with positive changes in win pct in win_pct across all levels
total_same_dyad <- length(unique(win_pct_changes2$dyad_id))
grouped_df_pos <- dplyr::group_by(win_pct_changes2_pos, feeder_occupancy_grouped)
unique_dyad_counts_pos <- dplyr::summarise(grouped_df_pos, n_unique_dyads = dplyr::n_distinct(dyad_id))
colnames(unique_dyad_counts_pos) <- c("feeder_occupancy_grouped", "dyads_pos_change")
unique_dyad_counts_pos$dyads_pos_change_pct <- unique_dyad_counts_pos$dyads_pos_change / total_same_dyad

