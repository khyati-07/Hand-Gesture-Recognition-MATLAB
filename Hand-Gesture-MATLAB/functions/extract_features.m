function features = extract_features(emgData)
    % Simple features: mean absolute value for each channel
    features = abs(emgData);  % [n_samples x 8]
end
