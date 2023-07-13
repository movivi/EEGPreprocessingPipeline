%Script6 #
%Uses the output from Script #5: script5.m
%This script loads the outputted continuous EEG data file with
%ICA-correction from Script #5,and first interpolates the bad channels identified
%in script5 then performs epoching with baseline correction, and then performs automatic residual artifact rejection.
close all; clearvars;

%Location of the main study directory
%This method of specifying the study directory only works if you run the script; for running individual lines of code, replace the study directory with the path on your computer,
DIR = fileparts(fileparts(mfilename('D:/EMP_data'))); 

%Location of the EEG data files
EEGDIR = fileparts(fileparts(mfilename('D:/EMP_data/eeg_eeglab'))); 

%Location of the folder that contains this script and any associated processing files
%This method of specifying the current file path only works if you run the script; for running individual lines of code, replace the current file path with the path on your computer,
Current_File_Path = fileparts(mfilename('D:/EMP_data/MATLAB_Scripts'));

%Load the Excel file with the list of channels to interpolate for each subject 
[ndata1, text1, alldata1] = xlsread('D:/EMP_data/MATLAB_Scripts/Interpolate_Channels');

%Load the Excel file with the list of thresholds and parameters for identifying C.R.A.P. with the simple voltage threshold algorithm for each subject 
[ndata2, text2, alldata2] = xlsread('D:/EMP_data/MATLAB_Scripts/AR_Parameters_for_SVT_CRAP');

%Load the Excel file with the list of thresholds and parameters for identifying eyeblinks during the stimulus presentation period (using the original non-ICA corrected VEOG signal) with the moving window peak-to-peak algorithm for each subject 
[ndata4, text4, alldata4] = xlsread('D:/EMP_data/MATLAB_Scripts/AR_Parameters_for_MW_Blinks');


%List of subjects to process, based on the name of the folder that contains that subject's data
SUB = {'01','02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33'};    
%*************************************************************************************************************************************

%Loop through each subject listed in SUB
for i = 1:length(SUB)

    %Open EEGLAB and ERPLAB Toolboxes
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

    %Define subject path based on study directory and subject ID of current subject
    Subject_Path = [EEGDIR];

    %Load the continuous EEG data file with IC weights corrected outputted from Script #5 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr'], 'gui', 'off'); 
    
    %Interpolate channel(s) specified in Excel file Interpolate_Channels.xls; any channel without channel locations (e.g., EOGS) should not be included in the interpolation process and are listed in ignored channels
    ignored_channels = [71:72];        
    DimensionsOfFile1 = size(alldata1);
    for j = 1:DimensionsOfFile1(1);
        if isequal(['EMP' SUB{i}],num2str(alldata1{j,1}));
           badchans = (alldata1{j,2});
           if ~isequal(badchans,'none') | ~isempty(badchans)
           	  if ~isnumeric(badchans)
                 badchans = str2num(badchans);
              end
              EEG  = pop_erplabInterpolateElectrodes( EEG , 'displayEEG',  0, 'ignoreChannels',  ignored_channels, 'interpolationMethod', 'spherical', 'replaceChannels', badchans);
           end
           [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'setname', [SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp.set'], 'gui', 'off'); 
        end
    end
    
    %Create EEG Event List containing a record of all event codes and their timing
    EEG  = pop_creabasiceventlist( EEG , 'AlphanumericCleaning', 'on', 'BoundaryNumeric', { -99 }, 'BoundaryString', { 'boundary' }, 'Eventlist', [Subject_Path 'EMP' SUB{i} '_Eventlist_POSTICA.txt'] ); 
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 3, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist.set'], 'gui', 'off');

    %Assign events to bins with Binlister; an individual trial may be assigned to more than one bin (bin assignments can be reviewed in each subject's Eventlist_Bins_POSTICA.txt file)
    %EEG  = pop_binlister( EEG , 'BDF', ['D:/EMP_data/MATLAB_Scripts/BDF_EMP.txt'], 'ExportEL', [Subject_Path 'EMP' SUB{i} '_Eventlist_Bins_POSTICA.txt'] );
    EEG  = pop_binlister( EEG , 'BDF', ['D:/EMP_data/MATLAB_Scripts/BDF_EMP.txt'], 'ExportEL', [Subject_Path 'EMP' SUB{i} '_Eventlist_Bins_POSTICA.txt'], 'IndexEL',  1, 'SendEL2', 'EEG&Text', 'UpdateEEG', 'off', 'Voutput', 'EEG' );
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 4, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist_bins'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist_bins.set'], 'gui', 'off'); 
    
    %Epoch the EEG into 0.7-second segments time-locked to the cue onset
    %(from -200 ms to 504 ms) and baseline correction between -200 to 0 ms
    EEG = pop_epochbin( EEG , [-200.0  504.0], [-200 0]);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 5, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist_bins_epoch'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist_bins_epoch.set'], 'gui', 'off'); 
    
    %Identify segments of EEG with C.R.A.P. artifacts using the simple voltage threshold algorithm with the parameters in the Excel file for each subject
    DimensionsOfFile2 = size(alldata2);
    for j = 1:DimensionsOfFile2(1)
        if isequal(['EMP' SUB{i}],num2str(alldata2{j,1}));
            if isequal(alldata2{j,2}, 'default')
                Channels = [1:70];
            else
                Channels = str2num(alldata2{j,2});
            end
            ThresholdMinimum = alldata2{j,3};
            ThresholdMaximum = alldata2{j,4};
            TimeWindowMinimum = alldata2{j,5};
            TimeWindowMaximum = alldata2{j,6};
        end
    end

    EEG  = pop_artextval( EEG , 'Channel',  Channels, 'Flag', [1 2], 'Threshold', [ThresholdMinimum ThresholdMaximum], 'Twindow', [TimeWindowMinimum  TimeWindowMaximum] ); 
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 6, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist_bins_epoch_SVT'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist_bins_epoch_SVT.set'], 'gui', 'off'); 

    
    %Identify segments of EEG with blink artifacts during the stimulus presentation window using the moving window peak-to-peak algorithm with the parameters in the Excel file for this subject
    DimensionsOfFile4 = size(alldata4);
    for j = 1:DimensionsOfFile4(1)
        if isequal(['EMP' SUB{i}],num2str(alldata4{j,1}));
            Channel = alldata4{j,2};
            if ~isequal(Channel,'none') | ~isempty(Channel)
           	  if ~isnumeric(Channel)
                 Channel = str2num(Channel);
              end
            Threshold = alldata4{j,3};
            TimeWindowMinimum = alldata4{j,4};
            TimeWindowMaximum = alldata4{j,5};
            WindowSize = alldata4{j,6};
            WindowStep = alldata4{j,7};
        end
        end
    end
    
    
   EEG  = pop_artmwppth( EEG , 'Channel',  Channel, 'Flag', [1 4], 'Threshold', Threshold, 'Twindow', [TimeWindowMinimum  TimeWindowMaximum], 'Windowsize', WindowSize, 'Windowstep', WindowStep ); 
  [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 7, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist_bins_epoch_SVT_MW1'], 'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr_interp_elist_bins_epoch_SVT_MW1.set'], 'gui', 'off'); 
  
%   %EEG marked artifacts removed for uploading purpose
%    EEG.BadTr = unique([find(EEG.reject.rejjp==1) find(EEG.reject.rejmanual==1)]);
%    EEG = pop_rejepoch( EEG, EEG.BadTr ,0);
%  %Save information about trial indices rejected
%     V_BadTrialsFile = fullfile(['EMP' SUB{i} '_Rejected_Trials_Indices_ERP.txt']);
%     dlmwrite(V_BadTrialsFile, EEG.BadTr, 'delimiter', ',');
%     
%     %Load the channel list with the additional clusters (e.g.
%     %parietal, frontocentral etc.) and re-reference to whole brain average
%     EEG = pop_eegchanoperator( EEG, 'D:/EMP_data/MATLAB_Scripts/electrode_clusters.txt');
%     [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 8, 'setname', ['EMP' SUB{i} '_preprocessed_final'], 'savenew', [Subject_Path 'EMP' SUB{i} '_preprocessed_final.set'], 'gui', 'off');   
%   
end