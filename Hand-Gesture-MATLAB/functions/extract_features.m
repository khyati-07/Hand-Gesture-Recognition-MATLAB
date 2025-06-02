% extract_features.m
% Extract features from EMG data

function [features, labels] = extract_features(emg_data, restimulus)
    % Parameters
    window_size = 200; % samples
    overlap = 100;     % samples
    num_channels = size(emg_data, 2);
    
    % Initialize
    features = [];
    labels = [];
    
    % Sliding window
    for i = 1:overlap:(size(emg_data, 1) - window_size)
        window = emg_data(i:i+window_size-1, :);
        label = mode(restimulus(i:i+window_size-1));
        
        % Skip rest periods
        if label == 0
            continue;
        end
        
        % Feature extraction: Mean Absolute Value (MAV)
        mav = mean(abs(window));
        
        % Concatenate features and labels
        features = [features; mav];
        labels = [labels; label];
    end
end
