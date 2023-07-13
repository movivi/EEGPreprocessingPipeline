%Script #3
%Uses the output from Script #2: script2.m
%This script loads the outputted semi-continuous EEG data file from Script #2,computes the ICA weights that will be used for artifact correction of ocular and muyscle artifacts, transfers the ICA weights to the 
%continuous EEG data file outputted from Script #1 (e.g., without the automatic continuous correction).
%PLEASE NOTE:
%The results of ICA decomposition using binica/runica (i.e., the ordering of the components, the scalp topographies, and the time courses of the components) will differ slightly each time ICA weights are computed.
%This is because ICA decomposition starts with a random weight matrix (and randomly shuffles the data order in each training step), so the convergence is slightly different every time it is run.

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

    %Load the semi-continuous binned EEG data file outputted from Script #2 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist_bins_epoch.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist_bins_epoch'], 'gui', 'off'); 

    %Compute ICA weights with runICA 
    EEG = pop_runica(EEG,'extended',1,'icatype', ['runica']); 
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist_bins_epoch_icaprep2_weighted'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist_bins_epoch_icaprep2_weighted.set'], 'gui', 'off');

    %Load the continuous EEG data file outputted from Script #1 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', ['EMP' SUB{i} '_DS_bpfilt_nhfilt.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt'], 'gui', 'off'); 
    
    %Transfer ICA weights to the continuous EEG data file (e.g., without the break periods and noisy segments of data removed)
    EEG = pop_editset(EEG, 'icachansind', 'ALLEEG(2).icachansind', 'icaweights', 'ALLEEG(2).icaweights', 'icasphere', 'ALLEEG(2).icasphere');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted.set'], 'gui', 'off');

end
    