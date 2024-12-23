% Load EEG data
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
datasetPath = 'C:\Users\user\Desktop\NYCU CS\大三上\腦機介面\HW2\dataset';
fileNames = {'S02_Sess05.set', 'S02_Sess05_rmcomp.set', 'S02_Sess05_filter_rmcomp.set'};
channelLabel = 'FCz';

% Process each dataset
for i = 1:numel(fileNames)
    % Load dataset
    EEG = pop_loadset('filename', fileNames{i}, 'filepath', datasetPath);
    
    % Select FCz channel for analysis
    fcz_chan = find(strcmpi({EEG.chanlocs.labels}, channelLabel));

    % Epoch EEG data for correct and wrong feedback
    EEG_correct = preprocess_epoch(EEG, 'FeedBack_correct');
    EEG_wrong = preprocess_epoch(EEG, 'FeedBack_wrong');

    % Compute ERP for correct and wrong trials
    erp_c = compute_mean_erp(EEG_correct, fcz_chan);
    erp_w = compute_mean_erp(EEG_wrong, fcz_chan);

    % Compute and display SNR
    SNR = compute_and_display_snr(erp_w, EEG_wrong.times);

    % Plot ERP for correct and wrong trials
    plot_erp(EEG_correct.times, erp_c, EEG_wrong.times, erp_w, sprintf('%s - %s', fileNames{i}, 'epochs'));
end

% Functions used in the script
function EEG_epoch = preprocess_epoch(EEG, event_type)
    EEG_epoch = pop_epoch(EEG, {event_type}, [-0.2 1.3], 'newname', 'epochs', 'epochinfo', 'yes');
    EEG_epoch = pop_rmbase(EEG_epoch, [-200 0], []);
end

function erp = compute_mean_erp(EEG_epoch, fcz_chan)
    erp = squeeze(mean(EEG_epoch.data(fcz_chan, :, :), 3));
end

function SNR = compute_and_display_snr(erp_w, times)
    peak_amp = max(erp_w);
    baseline_std = std(erp_w(times < 0));
    SNR = peak_amp / baseline_std;
    disp(['SNR: ', num2str(SNR)]);
end

function plot_erp(times_c, erp_c, times_w, erp_w, plotTitle)
    figure;
    hold on;
    plot(times_c, erp_c, 'Color', "#0072BD");
    plot(times_w, erp_w, 'Color', "#D95319");
    xlabel('ms');
    ylabel('amplitude');
    title(plotTitle);
    legend('correct', 'error');
end
