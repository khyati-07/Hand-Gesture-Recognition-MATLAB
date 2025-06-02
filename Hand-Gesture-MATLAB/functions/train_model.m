function train_model()
    % Build path relative to root
    matFile = fullfile('data', 'S1_A1_E1.mat');

    if ~isfile(matFile)
        error('Could not find EMG file at: %s', matFile);
    end

    data = load(matFile);
    
    % Use your real variable names here
    X = data.emg;         
    y = data.restimulus;  

    features = extract_features(X);
    model = fitcecoc(features, y);

    if ~exist('models', 'dir')
        mkdir('models');
    end

    save(fullfile('models', 'trained_model.mat'), 'model');
    disp('Model trained and saved.');
end
