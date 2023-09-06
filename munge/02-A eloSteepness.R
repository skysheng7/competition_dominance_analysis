###################################################################################################
############ Group Level Analysis: Steepness under different legels of feeder occupancy ###########
###################################################################################################
feed_replace_list <- replacement_list_by_date
clean_comb_list <- all.comb2

# identify days that need to be discarded
days_to_be_discarded <- warning_days[which(warning_days$Red_warning != ""),]

# track cow enroll and exclude data
cow_track_sheet <- cow_track(all.comb2)
cow_track_sheet <- merge(cow_track_sheet, days_to_be_discarded, all = TRUE) # delete days that has technical issues
cow_track_sheet <- cow_track_sheet[which(!is.na(cow_track_sheet$cow_num)),]
cow_track_sheet2 <- cow_track_sheet[which((cow_track_sheet$enroll_num != 0) | (cow_track_sheet$excluded_num != 0)),]
cow_track_sheet3 <- cow_track_sheet2[-which((!is.na(cow_track_sheet2$Red_warning)) & ((cow_track_sheet2$excluded_num > 12) | (cow_track_sheet2$enroll_num > 12))),]

# mark down regrouping days
regrouping <- cow_track_sheet5[which(cow_track_sheet3$enroll_num > 2),]

# process the raw datasheet containing cleaned feed & drinking data
master_comb5 <- feed_extra_processing(master_comb)
