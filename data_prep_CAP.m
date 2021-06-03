clearvars
clc
close all
%% -----
 % Get all .mat files for CAP dataset
 a = dir('*mat');
 freq_spects = [];
 freq_spects_labels = []; 
 
 % Select patients for the testing
 for i = 21:40
    
     data = load(a(i).name).VoltSegments;
     sampling_rate_of_segment = length(data{1,1}) / 30;
     
         for k = 1:6
             if isempty(data{k,1})
                 ceb = 0;
             else
                 for l = 1:length(data{k,1}(1,:))
                     processed_data = data{k,1}(:,l);
                     % Change the sampling rate if it is not 100 Hz
                     if sampling_rate_of_segment ~= 100
                         processed_data = resample(processed_data, 100,sampling_rate_of_segment);
                     end
                     % Calculate the Multitaper power spectral density
                     [pxx1,freq1] = pmtm(processed_data,15,length(processed_data),100);
                     % Downsample the PSDs
                     pxx = downsample(pxx1,5);
                     % Log power 
                     freq_spects = [freq_spects ; log10(pxx).'];
                     if k == 1 %Wake
                         freq_spects_labels = [freq_spects_labels ; 0];
                     elseif k == 2  %N1
                         freq_spects_labels = [freq_spects_labels ; 1];
                     elseif k == 3 %N2
                         freq_spects_labels = [freq_spects_labels ; 2];
                     elseif k == 4 || k==5 %N3 and N4
                         freq_spects_labels = [freq_spects_labels ; 3];
                     elseif k == 6 % REM
                         freq_spects_labels = [freq_spects_labels ; 4];
                     end
                 end
             end
         end
 end
 
freq_spects_train = [];
freq_spects_labels_train = []; 

% Select patients for the training
 for i = [1:20 41:100]
     data = load(a(i).name).VoltSegments;
     sampling_rate_of_segment = length(data{1,1}) / 30;
     
         for k = 1:6
             if isempty(data{k,1})
                 ceb = 0;
             else
                 for l = 1:length(data{k,1}(1,:))
                     processed_data = data{k,1}(:,l);
                     if sampling_rate_of_segment ~= 100
                         processed_data = resample(processed_data, 100,sampling_rate_of_segment);
                     end
                     [pxx1,freq1] = pmtm(processed_data,15,length(processed_data),100);
                     pxx = downsample(pxx1,5);
                     freq_spects_train = [freq_spects_train ; log10(pxx).'];
                     if k == 1 %Wake
                         freq_spects_labels_train = [freq_spects_labels_train ; 0];
                     elseif k == 2  %N1
                         freq_spects_labels_train = [freq_spects_labels_train ; 1];
                     elseif k == 3 %N2
                         freq_spects_labels_train = [freq_spects_labels_train ; 2];
                     elseif k == 4 || k == 5 %N3 and N4
                         freq_spects_labels_train = [freq_spects_labels_train ; 3];
                     elseif k == 6 % REM
                         freq_spects_labels_train = [freq_spects_labels_train ; 4];
                     end
                 end
             end
         end
 end
 
Xtrain = freq_spects_train;
Ytrain = freq_spects_labels_train;
Xtest = freq_spects;
Ytest = freq_spects_labels;

CV1 = []; 
CV1.xtrain = Xtrain;
CV1.ytrain = Ytrain;
CV1.xtest = Xtest;
CV1.ytest = Ytest;
save('CV1.mat','CV1');
 
 