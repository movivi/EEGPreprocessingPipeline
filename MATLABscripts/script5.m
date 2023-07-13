%Script5 #
%Uses the output from Script #4: script4.m
%This script loads the outputted continuous EEG data file with ICA
%weights from Script #3,and removes the IC weights identified by ADJUST
%plugin (Mognon et al., 2011) and perform automatic bad channel detection
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

    %Load the continuous EEG data file with IC weights outputted from Script #3 in .set EEGLAB file format
    EEG = pop_loadset( 'filename', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted.set'], 'filepath', Subject_Path);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'setname', ['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted'], 'gui', 'off'); 
    
    %Load list of ICA component(s) corresponding to ocular and muscle artifacts from Excel file ICA_Components.xlsx
    [ndata, text, alldata] = xlsread('D:/EMP_data/MATLAB_Scripts/ICA_Components.xlsx'); 
    MaxNumComponents = size(alldata, 2);
        for j = 1:length(alldata)
            if isequal(['EMP' SUB{i}], num2str(alldata{j,1}));
                NumComponents = 0;
                for k = 2:MaxNumComponents
                    if ~isnan(alldata{j,k});
                        NumComponents = NumComponents+1;
                    end
                    Components = [alldata{j,(2:(NumComponents+1))}];
                end
            end
        end

    %Perform ocular, generic discontinuity correction by removing the ICA component(s) specified above
    EEG = pop_subcomp( EEG, [Components], 0);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2,'setname',['EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr'],'savenew', [Subject_Path 'EMP' SUB{i} '_DS_bpfilt_nhfilt_weighted_ica_corr.set'],'gui','off'); 
    
    %Apply automatic bad channel rejection Post-ICA using spectrum measure
    [EEG, V_Channels_Excluded] = pop_rejchan(EEG, 'elec',[1:72],'threshold',5,'norm','on','measure','kurt');
    
    %Save information about Bad Channels Post-ICA
    V_BadChannelsFile = fullfile(['EMP' SUB{i} '_Bad_Channel_Indices_POSTICA.txt']);
    dlmwrite(V_BadChannelsFile, V_Channels_Excluded, 'delimiter', ',');

end