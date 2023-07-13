%Script4 #
%Uses the output from Script #3: script3.m
%This script loads the outputted semi-continuous EEG data file with ICA
%weights from Script #3,and removes POz channel and then does automatic IC weight removal using ADJUST
%plugin (Mognon et al., 2011)
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

    %Load the semi-continuous binned EEG data file with ICA weights outputted from Script #3 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist_bins_epoch_icaprep2_weighted.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem_elist_bins_epoch_icaprep2_weighted'], 'gui', 'off'); 
    
    %Remove POz
    EEG = pop_select( EEG, 'nochannel',{'POz'});
    
    %Automatic IC weight rejection using ADJUST
    EEG = interface_ADJ (EEG,[SUB{i} 'report.txt']);
    
end
