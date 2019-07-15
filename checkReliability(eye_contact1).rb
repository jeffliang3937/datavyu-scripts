require 'Datavyu_API.rb'
begin

# Checking reliability for onset/offset times for eye contact. Problem: No matching arg

main_col = getColumn("eye_contact")
rel_col = getColumn("eye_contact_2")
  
# Create two-dimensional arrays for onset/offset times of main and rel cols, note cannot index with RCell since RCell cannot be converted to int
main_col_times = Array.new
for mc in main_col.cells
	main_col_times << [mc.onset, mc.offset] # << appends to array
end
rel_col_times = Array.new
for rc in rel_col.cells
	rel_col_times << [rc.onset, rc.offset]
end
	
# Now check each pair in rel times to see if they are within the range of one of the pairs in main col times using accumulators

total_successes = 0 
total_rel_cells = 0
not_errors = Array.new
errors = Array.new

for cell in rel_col.cells
	total_rel_cells = total_rel_cells + 1
	errors << cell.onset
end 

for pair1 in rel_col_times
	for pair2 in main_col_times
		if (pair1[0] - pair2[0]).abs <= 2000 and (pair1[1] - pair2[1]).abs <= 2000
			total_successes = total_successes + 1
			not_errors << pair1[0]
			break
		end
	end
end 

# Print errors

errors = errors - not_errors
i = 1

for error in errors
	error = (error/1000.0)
	puts "(" + i.to_s + ") No match for reliability cell at onset time: " + error.to_s + " seconds\n\n"
	i = i + 1
end

total_rel_cells = total_rel_cells.to_f
total_successes = total_successes.to_f

percent_reliability = (total_successes / total_rel_cells) * 100
print "Total number of reliability cells: " + total_rel_cells.to_s + "\n"
print "Total number of reliability cells with matching times: " + total_successes.to_s + "\n"
rel_string = "Percentage of reliable cells: " + percent_reliability.to_s + "% \n"
print rel_string

# Report total duration for each column

total_duration_main_col = 0.0
total_duration_rel_col = 0.0

for cell in main_col.cells
	duration = (cell.offset - cell.onset)
	total_duration_main_col = total_duration_main_col + duration
end
total_duration_main_col = total_duration_main_col/1000.0
print "Total duration reported for eye_contact: " + total_duration_main_col.to_s + " seconds.\n"

for cell in rel_col.cells
	duration = (cell.offset - cell.onset)
	total_duration_rel_col = total_duration_rel_col + duration
end

total_duration_rel_col = total_duration_rel_col/1000.0
print "Total duration reported for eye_contact_2: " + total_duration_rel_col.to_s + " seconds.\n"

# Check percentage of how long participant makes eye contact while PEER is speaking

peer_col = getColumn("peer")
peer_times = Array.new
for cell in peer_col.cells
	peer_times << [cell.onset, cell.offset]
end 

ec_during = 0.0

# Check if peer speaking interval falls within eye contact time
for interval in peer_times
	for time in main_col_times
		if interval[0] >= time[0] and interval[1] <= time[1]
			ec_during = ec_during + (interval[1] - interval[0])
			puts "(1) MATCH AT " + interval[0].to_s + " - " + interval[1].to_s + "\n"
			break
		end
		# BOGUS values - due to iterating through ALL intervals: try adding another condition such as less than the next onset 
		#if interval[0] >= time[0] and interval[1] >= time[1] # and less than onset of next cell...?
		#	ec_during = ec_during + (interval[1] - time[0])
		#	puts "(2) MATCH AT " + interval[0].to_s + " - " + interval[1].to_s + "\n"
		#	break
		#end
		#if interval[0] <= time[0] and interval[1] <= time[1] # also needs another condition otherwise will count all cells matching condition
		#	ec_during = ec_during + (interval[1] - time[0])
		#	break
		#end
		#if interval[0] <= time[0] and interval[1] >= time[1]
		#	ec_during = ec_during + (time[1] - time[0])
		#	break
	end
end

print "Total duration of eye contact while peer speaking (as reported by first coder): " + (ec_during/1000.0).to_s + " seconds\n"

ec_during_2 = 0.0
 
for interval in peer_times
	for time in rel_col_times
		if interval[0] >= time[0] and interval[1] <= time[1]
			ec_during_2 = ec_during_2 + (interval[1] - interval[0])
			break
		end
		if time[0] >= interval[0] and time[1] <= interval[1] 
			ec_during_2 = ec_during_2 + (time[1] - time[0])
			break
		end
	end
end

#print "Total duration of eye contact while peer speaking (as reported by second coder): " + (ec_during_2/1000.0).to_s + " seconds\n"

# KAPPA STATISTIC: P0 using % agreement, Pe using durations

#  speaker_listener = getColumn("speaker_listener")
#  end_transcription = speaker_listener.cells[-1].offset

# p_e = ((total_duration_main_col*1000/end_transcription) * (total_duration_rel_col*1000/end_transcription)) + ((total_duration_main_col*1000/end_transcription) * (total_duration_main_col*1000/end_transcription))
# kappa = ((percent_reliability/100) - p_e)/(1 - p_e)

#print "Kappa = " + kappa.to_s + "\n"

end