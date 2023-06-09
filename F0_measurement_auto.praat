# Albert Baichen Du
# An automatic F0 measurement script that samples x number of points in target tier of target files.
# Last Update: Jul 26, 2022

# Select speaker, tier, gender and measurement points
form Settings
    sentence file_name 172_20210310
    sentence annotator_initials BD
    comment Tier number of the target speaker's utterances :
	positive speaker_tier 6
	comment Label for the target speaker:
	sentence speaker FA1
	comment Biological gender of the target speaker
	sentence gender F
	comment Tier number of xds :
	positive xds_tier 7
	comment Number of sampling points :
    natural measurement_points 20 (= Every 5%)
endform

# Define Pitch Floor
if gender$ == "F"
	pitch_floor = 100
elif gender$ == "M"
	pitch_floor = 75
endif

# Define output file's formant
output_file$ = "F0_" + file_name$ + "_" + speaker$ + "_" + annotator_initials$ + ".csv"
appendFile: output_file$, "file_name", ",", "speaker", ",", "usability", ",", "xds", ",",  "interval_start", ",", "interval_end", ",", "pitch_min", ",", "pitch_max", ",", "pitch_mean", ",", "pitch_sd", ",", "F0_00", ",", "F0_05", ",", "F0_10", ",", "F0_15", ",", "F0_20", ",", "F0_25", ",", "F0_30", ",", "F0_35", ",", "F0_40", ",", "F0_45", ",", "F0_50", ",", "F0_55", ",", "F0_60", ",", "F0_65", ",", "F0_70", ",", "F0_75", ",", "F0_80", ",", "F0_85", ",", "F0_90", ",", "F0_95", ",", "F0_100"
appendFile: output_file$, newline$

# Open target audio and TextGrid
wav = Open long sound file: file_name$ + ".wav"
tgfile$ = file_name$ + "_" + annotator_initials$ + ".TextGrid"

# Measurement
selectObject: wav
	# Select files
	tg = Read from file: tgfile$
	nInt = Get number of intervals: speaker_tier

	# From the first to the last interval...
	for i to nInt
	    selectObject: tg
	    speaker_interval$ = Get label of interval: speaker_tier, i

	    if speaker_interval$ = "0." or speaker_interval$ = "noisy" or speaker_interval$ = "faint" or speaker_interval$ = "overlap"

	    # Set usability
	    usability$ = speaker_interval$

	    selectObject: tg

	    # Get the start and the end of the interval
	    interval_start = Get start time of interval: speaker_tier, i
	    interval_end = Get end time of interval: speaker_tier, i

	    # Get the xds
	    xds$ = Get label of interval: xds_tier, i

	    # Also get the duration, just in case
	    duration = interval_end - interval_start

	    appendInfoLine: speaker_interval$

	    # Extract that interval to a separate chunk
	    tg_chunk = Extract part: interval_start, interval_end, "yes"

	    # Extract that interval's audio to a separate chunk
	    selectObject: wav
	    wav_chunck = Extract part: interval_start, interval_end, "yes"

	    # Create a new pitch object of that chunk
	    selectObject: wav_chunck
	    pitch_chunk = To Pitch: 0, pitch_floor, 600

	    # Measure the pitch object
	    selectObject: pitch_chunk

	        pitches$ = ""
	        for t from 0 to measurement_points
	            percent = t * (1/measurement_points)
	            time_percent = interval_start + (percent * duration)

	            pitch_interval = Get value at time: time_percent, "Hertz", "Linear"
	            pitches$ = pitches$ + string$(pitch_interval) + ","
	        endfor

	        pitch_min$ = Get minimum: interval_start, interval_end, "Hertz", "Parabolic"
	        pitch_max$ = Get maximum: interval_start, interval_end, "Hertz", "Parabolic"
	        pitch_mean$ = Get mean: interval_start, interval_end, "Hertz"
	        pitch_sd$ = Get standard deviation: interval_start, interval_end, "Hertz"


	    appendFile: output_file$, file_name$, ",", speaker$, ",", usability$, ",", xds$, ",", interval_start, ",", interval_end, ",", pitch_min$, ",", pitch_max$, ",", pitch_mean$, ",", pitch_sd$, ","
	    appendFile: output_file$, pitches$
	    appendFile: output_file$, newline$
	                 
	    removeObject: wav_chunck
	    removeObject: tg_chunk
	    removeObject: pitch_chunk

	    endif
	endfor

appendInfoLine: "Finished! Press Command+W to quit."
