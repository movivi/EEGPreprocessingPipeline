%Script #2
%Uses the output from Script #1: script1.m
%This script loads the outputted semi-continuous EEG data file from Script #1,
%does epoching.
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

    %Load the semi-continuous EEG data file outputted from Script #1 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem'], 'gui', 'off'); 

    %Create EEG Event List containing a record of all event codes and their timing
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist', [Subject_Path 'EMP' SUB{i} '_Eventlist.txt'] ); 
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist.set'], 'gui', 'off');

    %Assign events to bins with Binlister; an individual trial may be assigned to more than one bin (bin assignments can be reviewed in each subject's LWM_Eventlist_Bins.txt file)
    EEG  = pop_binlister( EEG , 'BDF', ['D:/EMP_data/MATLAB_Scripts/BDF_EMP.txt'], 'ExportEL', [Subject_Path 'EMP' SUB{i} '_Eventlist_Bins.txt'], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'UpdateEEG', 'on', 'Voutput', 'EEG' );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist_bins'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist_bins.set'], 'gui', 'off'); 
    
    %Epoch the EEG into 0.7-second segments time-locked to the cue onset
    %(from -200 ms to 504 ms) and no baseline correction now (will be
    %performed post-ICA)
    EEG = pop_epochbin( EEG , [-200.0  504.0], 'none');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist_bins_epoch'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist_bins_epoch.set'], 'gui', 'off');
   
    
%End subject loop
end

%*************************************************************************************************************************************
