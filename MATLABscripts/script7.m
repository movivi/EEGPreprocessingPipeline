%Script7 #
%Uses the output from Script #6: script6.m
%This script loads the outputted artifact corrected semi-continuous EEG data file with
%ICA-correction from Script #6,and re-references to whole-brain average, then creates an averaged ERP waveform, calculates the percentage of trials rejected for artifacts (in total and per bin) 
%and saves the information to a .csv file; and finally performs grand
%averaging of ERP waveforms
close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer,
DIR = fileparts(fileparts(mfilename('D:/EMP_data'))); 

%Location of the EEG data files
EEGDIR = fileparts(fileparts(mfilename('D:/EMP_data/eeg_eeglab'))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer,
Current_File_Path = fileparts(mfilename('D:/EMP_data/MATLAB_Scripts'));

%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'01','02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33'};    
%*************************************************************************************************************************************

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Open EEGLAB and ERPLAB Toolboxes
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [EEGDIR];

    %Load the artifact marked continuous binned EEG data file with IC weights corrected outputted from Script #6 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist_bins_epoch_SVT_MW1.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist_bins_epoch_SVT_MW1'], 'gui', 'off'); 
    
    %Load the channel list with the additional clusters (e.g.
    %parietal, frontocentral etc.) and re-reference to whole brain average
    EEG = pop_eegchanoperator( EEG, 'D:/EMP_data/MATLAB_Scripts/electrode_clusters.txt');
   
    %Create an averaged ERP waveform
    ERP = pop_averager( EEG , 'Criterion', 'good', 'ExcludeBoundary', 'on', 'SEM', 'on');
    ERP = pop_savemyerp( ERP, 'erpname', ['EMP' SUB{i} '_erp_ar'], 'filename', [Subject_Path 'EMP' SUB{i} '_erp_ar.erp']);
    
    %Calculate the percentage of trials that were rejected in each bin 
    accepted = ERP.ntrials.accepted;
    rejected= ERP.ntrials.rejected;
    percent_rejected= rejected./(accepted + rejected)*100;
    
    %Calculate the total percentage of trials rejected across all trial types
    total_accepted = accepted(1) + accepted(2);
    total_rejected= rejected(1)+ rejected(2);
    total_percent_rejected= total_rejected./(total_accepted + total_rejected)*100; 
    
    %Save the percentage of trials rejected (in total and per bin) to a .csv file 
    fid = fopen([SUB{i} '_AR_Percentages.csv'], 'w');
    fprintf(fid, 'SubID,Bin,Accepted,Rejected,Total Percent Rejected\n');
    fprintf(fid, '%s,%s,%d,%d,%.2f\n', SUB{i}, 'Total', total_accepted, total_rejected, total_percent_rejected);
    bins = strrep(ERP.bindescr,', ',' - ');
    for b = 1:length(bins)
        fprintf(fid, ',%s,%d,%d,%.2f\n', bins{b}, accepted(b), rejected(b), percent_rejected(b));
    end
    fclose(fid);
    
    %Create ERP difference waveforms between conditions
    ERP = pop_binoperator( ERP, ['D:/EMP_data/MATLAB_Scripts/Diff_Wave.txt']);
    ERP = pop_savemyerp(ERP, 'erpname', ['EMP' SUB{i} '_erp_ar_diff_waves'], 'filename', [Subject_Path 'EMP' SUB{i} '_erp_ar_diff_waves.erp']);
    
    %Apply a low-pass filter (non-causal Butterworth impulse response function, 20 Hz half-amplitude cut-off, 48 dB/oct roll-off) to the difference waveforms
    ERP = pop_filterp( ERP,  1:75 , 'Cutoff',  20, 'Design', 'butter', 'Filter', 'lowpass', 'Order',  8 );
    ERP = pop_savemyerp( ERP, 'erpname', ['EMP' SUB{i} '_erp_ar_diff_waves_lpfilt'], 'filename', [Subject_Path 'EMP' SUB{i} '_erp_ar_diff_waves_lpfilt.erp']);
    

end

%Create grand average ERP waveforms from individual subject ERPs without low-pass filter applied 

%Open EEGLAB and ERPLAB Toolboxes  
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

%Create a text file containing a list of ERPsets and their file locations to include in the grand average ERP waveforms
    ERPset_list = fullfile('D:/EMP_data/MATLAB_Scripts/GA_erp_ar_diff_waves.txt');
    fid = fopen(ERPset_list, 'w');
    for i = 1:length(SUB)
        erppath = ['EMP' SUB{i} '_erp_ar_diff_waves.erp'];
        fprintf(fid,'%s\n', erppath);
    end
    fclose(fid);

    %Create a grand average ERP waveform
    ERP = pop_gaverager( ERPset_list , 'ExcludeNullBin', 'on', 'SEM', 'on' );
    ERP = pop_savemyerp(ERP, 'erpname', 'GA_erp_ar_diff_waves', 'filename', 'GA_erp_ar_diff_waves.erp', 'filepath', EEGDIR, 'Warning', 'off');