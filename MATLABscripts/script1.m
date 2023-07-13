%Script #1
%This script loads the raw continuous EEG data in .set EEGLAB file format, downsamples the data to 250 Hz to speed data processing time,
%removes the DC offsets, and applies a band-pass filter and notch filter, and 
%does automatic continuous and bad channel rejection for ica-preparation

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

%***********************************************************************************************************************************************

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Open EEGLAB and ERPLAB Toolboxes
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [EEGDIR];

    %Load the raw continuous EEG data file in .set EEGLAB file format
    EEG = pop_loadset( 'filename', ['EMP' SUB{i} '.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', ['EMP' SUB{i} '.set'], 'gui', 'off'); 
    
    %Downsample from the recorded sampling rate of 512 Hz to 250 Hz to speed data processing (automatically applies the appropriate low-pass anti-aliasing filter)
    EEG = pop_resample( EEG, 250);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',['EMP' SUB{i} '_DS.set'],'savenew',[Subject_Path 'EMP' SUB{i} '_DS.set'] ,'gui','off'); 
    
    %Remove DC offsets and apply a band-pass filter (non-causal Butterworth impulse response function, 0.1 Hz high pass and 30.0 low pass half-amplitude cut-off, 12 dB/oct roll-off)
    EEG  = pop_basicfilter( EEG,  1:72 , 'Boundary', 'boundary', 'Cutoff',  [ 0.1 30], 'Design', 'butter', 'Filter', 'bandpass', 'Order',  2, 'RemoveDC', 'on' );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4, 'setname', ['EMP' SUB{i} '_DS_bpfilt.set'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt.set'], 'gui', 'off');
    
    %Apply Parks-McClellan notch filter at 50 Hz to reduce power line noise
    EEG  = pop_basicfilter( EEG,  1:72 , 'Boundary', 'boundary', 'Cutoff',  50, 'Design', 'notch', 'Filter', 'PMnotch', 'Order',  180 );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt.set'], 'gui', 'off');

    %Load parameters for rejecting especially noisy segments of EEG during trial blocks from Excel file ICA_Prep_Values.xls.
    %Parameters set currently are peak amplitude +- 100 uV, moving window 500 ms and moving window step at 50 ms but they can 
    % be modified for a given participant on the basis of visual inspection
    % of the data. Ideal values: peak amplitude +- 100 uV, moving window 500 ms and moving window step at 50 ms
    [ndata, text, alldata] = xlsread('D:/EMP_data/MATLAB_Scripts/ICA_Prep_Values.xlsx'); 
        for j = 1:length(alldata)           
            if isequal(['EMP' SUB{i}],num2str(alldata{j,1}));
                AmpthValue = alldata{j,2};
                WindowValue = alldata{j,3};
                StepValue = alldata{j,4};
            end
        end

    %Delete segments of the EEG exceeding the thresholds defined above
    %(exclude EOG channels)
    EEG = pop_continuousartdet( EEG, 'ampth', AmpthValue, 'winms', WindowValue, 'stepms', StepValue, 'chanArray', [1:70], 'review', 'off');        
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep.set'], 'gui', 'off'); 

    
    %Apply automatic bad channel rejection Pre-ICA using kurtosis measure
    [EEG, V_Channels_Excluded] = pop_rejchan(EEG, 'elec',[1:72],'threshold',5,'norm','on','measure','kurt');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 7, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_icaprep_badchanrem.set'], 'gui', 'off');

    %Save information about Bad Channels excluded Pre-ICA
    V_BadChannelsFile = fullfile(['EMP' SUB{i} '_Bad_Channel_Indices.txt']);
    dlmwrite(V_BadChannelsFile, V_Channels_Excluded, 'delimiter', ',');

%End subject loop
end
%***********************************************************************************************************************************************
