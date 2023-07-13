# EEGPreprocessingPipeline

This repository contains **MATLAB** scripts and relevant csv/txt files I compiled as part of one of the analysis teams for [**EEGManyPipelines**](https://www.eegmanypipelines.org)

For testing the reproducibility of my scripts, I provide 2 minimally processed EEG datasets (in **EEGLAB** compatible formats: *.set* and *.fdt*) [<ins>**here**</ins>](https://www.dropbox.com/sh/8qf0adaveg65j1z/AAAw10gHazrtStDz9nQoCwfAa?dl=0)

## EEG Data Overview (For more info, please refer to this [documentation](https://www.dropbox.com/scl/fi/a70rq72ntqn55dx31pj71/EMP_dataset_documentation.pdf?rlkey=2zc65hp4wl0ochlj3415n2vx4&dl=0))
1. Total channels: 72
2. Channel Number and Label (Displaying 70 channels; Ch71, Ch72 computed from other channels):
![image](https://github.com/movivi/EEGPreprocessingPipeline/assets/46511747/e015d5b0-700a-406b-a8c2-fa91deb9924f)
3. Ch71: vertical EOG (computed by subtracting infra-orbital channels IO1 and IO2 (Ch67, Ch68) from the corresponding super-orbital channels FP1 and FP2 (Ch1, Ch34)
4. Ch72: horizontal EOG (computed by subtracting right channel Afp10 (Ch66) from the corresponding left channel Afp9 (Ch65)
5. Referenced to channel POz (Ch30)
6. Downsampled to 512 Hz

## Mo's Pre-processing Pipeline Overview
Following is the outline of the preprocessing steps (for further details, please refer to annotations within the individual **MATLAB** scripts):
1. Data downsampling to **250 Hz**
2. Bandpass filter (**0.1 Hz and 30 Hz**)
3. Notch filter (**50 Hz**)
4. Removal of noisy segments of continuous EEG data pre-ICA using pop_continuousartdet (**+-100 uV threshold; moving window size = 500 ms; moving window step = 50 ms; exclude EOG channels**) 
5. Automatic bad channel rejection pre-ICA using pop_rejchan (**kurtosis measure; threshold = 5**)
6. Create EVENTLIST and add events to BINLISTER
7. Epoch trials (**-200 to 504 ms**) without baseline correction
8. Perform ICA using runICA algorithm
9. Transfer ICA weights to continuous EEG data (EEG data obtained after Step 3)
10. Automatic IC weight rejection on continuous EEG data using [**ADJUST**](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1469-8986.2010.01061.x)
11. Automatic bad channel detection post-ICA using pop_rejchan (**kurtosis measure; threshold = 5**)
12. Interpolation of bad channels detected post-ICA (Spherical method)
13. Create EVENTLIST and add events to BINLISTER
14. Epoch trials (**-200 to 504 ms**) and perform baseline correction (**-200 to 0 ms**)
15. Automatic artifact rejection on all channels (exclude EOG channels) using simple voltage threshold algorithm (**+-100 uV threshold; time window = -200 to 500**)
16. Automatic blink artifact removal on EOG channels using moving window peak-to-peak algorithm (**threshold = 150 uV; moving window size = 225; window step = 10 ms**)
17. Re-reference to whole brain average (exclude EOG and mastoid channels from the average) and add additional channel clusters (e.g. frontocental, posterior)
18. Create averaged ERP waveforms

## Credit
Data courtesy: **Niko Busch** and **EEGManyPipelines**

EEG Data documentation and scalp maps with channel info: **Niko Busch**

Most of if not all the EEG/ERP preprocessing I learnt from fantastic [*online resources*](https://erpinfo.org/erplab) by **Steve Luck**, **Emily Kappenman** and **Arnold Delorme** (especially his tutorials on [*youtube*](https://youtube.com/playlist?list=PLXc9qfVbMMN2uDadxZ_OEsHjzcRtlLNxc)), so **Huge thanks** to my *virtual* teachers 💛


