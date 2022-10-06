
% [load eeglab ]
% run('eeglab.m')
eeglab

[data_ch1,Fs] = audioread(['0_source_ch1.wav']);
[data_ch2,Fs] = audioread(fullfile('data','0_source_ch2.wav'));
[data_ch3,Fs] = audioread(fullfile('data','0_source_ch3.wav'));
[data_ch4,Fs] = audioread(fullfile('data','0_source_ch4.wav'));

data_sound = [data_ch1 data_ch2 data_ch3 data_ch4]';

% Eigenvalue simulation
target_eig = [1e-1 1e-2 1e-3 1e-4 1e-5 1e-6 1e-7 1e-8 1e-9 1e-10 1e-11 1e-12];
for nEig = 1:length(target_eig)

    rho = 1-target_eig(nEig);

    mat_mixing = [1 rho 0.5 0.5;
        rho 1 0.5 0.5;
        0.5 0.5 1 0.5;
        0.5 0.5 0.5 1];

    data_eeg = mat_mixing*data_sound;


    EEG = pop_importdata('dataformat','array','nbchan',0,'data','data_eeg','srate',Fs,'pnts',0,'xmin',0);
    EEG = eeg_checkset( EEG );
    EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1);

    for nCh = 1:4
        data_save = EEG.data(nCh,:)/max(abs(EEG.data(nCh,:)));
        file_name = ['1_eig' num2str(nEig) '_mixed_ch' num2str(nCh) '.wav'];
        audiowrite(file_name,data_save,Fs)

        try
            file_name = ['1_eig' num2str(nEig) '_decomposed_ch' num2str(nCh) '.wav'];
            data_save = EEG.icaact(nCh,:);
            data_save = data_save/max(abs(data_save));
            audiowrite(file_name,data_save,Fs)
        catch
        end
    end
    clc
    disp(sprintf('nEig: %d/%d',nEig,length(target_eig)))
end


% Several confirmatory demonstrations

mat_mixing = [1 0.9 0.8 0.8;
    0.8 1 0.7 0.9;
    0.7 0.8 1 0.9;
    0.6 0.8 0.7 1];

data_eeg = mat_mixing*data_sound;
L = length(data_eeg);

% (1) Time-invariant property by shuffling the 1-s time blocks
EEG = pop_importdata('dataformat','array','nbchan',0,'data','data_eeg','srate',Fs,'pnts',0,'xmin',0);
EEG = eeg_checkset( EEG );
icell_segment = mat2cell([1:L],1,[Fs*ones(1,floor(L/(Fs))) L-(Fs)*floor(L/(Fs))]);
iCell_shuffle = randperm(length(icell_segment));
i_shuffle = ([icell_segment{iCell_shuffle}]);
EEG.data = EEG.data(:,i_shuffle);
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1);

for nCh = 1:4
    try
        file_name = ['2_time_shuffle_mixed_ch' num2str(nCh) '.wav'];
        data_save = EEG.data(nCh,:)/max(abs(EEG.data(nCh,:)));
        audiowrite(file_name,data_save,Fs)
    catch
    end

    try
        file_name = ['2_time_shuffle_decomposed_ch' num2str(nCh) '.wav'];
        data_save = EEG.icaact(nCh,:)/max(abs(EEG.icaact(nCh,:)));
        audiowrite(file_name,data_save,Fs)
    catch
    end
end



% (2) Undercomplete (3 sources, 4 mixings) without PCA
EEG = pop_importdata('dataformat','array','nbchan',0,'data','data_eeg','srate',Fs,'pnts',0,'xmin',0);
EEG = eeg_checkset( EEG );
EEG.data = mat_mixing*data_sound([1 1 2 3],:);
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1);
for nCh = 1:4
    try
        file_name = ['3_undercomplete_wo_pca_mixed_ch' num2str(nCh) '.wav'];
        data_save = EEG.data(nCh,:)/max(abs(EEG.data(nCh,:)));
        audiowrite(file_name,data_save,Fs)
    catch
    end

    try
        file_name = ['3_undercomplete_wo_pca_decomposed_ch' num2str(nCh) '.wav'];
        data_save = EEG.icaact(nCh,:)/max(abs(EEG.icaact(nCh,:)));
        audiowrite(file_name,data_save,Fs)
    catch
    end
end



% (3) Undercomplete (3 sources, 4 mixings) (with PCA)
EEG = pop_importdata('dataformat','array','nbchan',0,'data','data_eeg','srate',Fs,'pnts',0,'xmin',0);
EEG = eeg_checkset( EEG );
EEG.data = mat_mixing*data_sound([1 1 2 3],:);
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'pca',3);
for nCh = 1:4
    try
        file_name = ['4_undercomplete_w_pca_mixed_ch' num2str(nCh) '.wav'];
        data_save = EEG.data(nCh,:)/max(abs(EEG.data(nCh,:)));
        audiowrite(file_name,data_save,Fs)
    catch
    end

    try
        file_name = ['4_undercomplete_w_pca_decomposed_ch' num2str(nCh) '.wav'];
        data_save = EEG.icaact(nCh,:)/max(abs(EEG.icaact(nCh,:)));
        audiowrite(file_name,data_save,Fs)
    catch
    end
end



% (4) Overcomplete (4 sources, 3 mixings)
EEG = pop_importdata('dataformat','array','nbchan',0,'data','data_eeg','srate',Fs,'pnts',0,'xmin',0);
EEG = eeg_checkset( EEG );
EEG = pop_select( EEG,'nochannel',4);
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1);

for nCh = 1:4
    try
        file_name = ['5_overcomplete_mixed_ch' num2str(nCh) '.wav'];
        data_save = EEG.data(nCh,:)/max(abs(EEG.data(nCh,:)));
        audiowrite(file_name,data_save,Fs)
    catch
    end

    try
        file_name = ['5_overcomplete_decomposed_ch' num2str(nCh) '.wav'];
        data_save = EEG.icaact(nCh,:)/max(abs(EEG.icaact(nCh,:)));
        audiowrite(file_name,data_save,Fs)
    catch
    end
end
