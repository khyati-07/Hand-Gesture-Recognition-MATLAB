function train_model(split_type)
    fs = 2000;  % Ninapro sampling rate

    data_files = dir('data/*.mat');
    if numel(data_files) < 3
        error('At least 3 .mat files required for byfile split.');
    end

    X = []; Y = [];

    % Load and preprocess all files
    for i = 1:numel(data_files)
        data = load(fullfile('data', data_files(i).name));
        emg = preprocess_emg(data.emg, fs);
        labels = data.restimulus;

        window = round(0.2 * fs);
        step = round(0.1 * fs);

        for t = 1:step:(size(emg, 1) - window)
            win = emg(t:t+window-1, :);
            label = mode(labels(t:t+window-1));
            if label == 0, continue; end
            feats = extract_features(win);
            X = [X; feats];
            Y = [Y; label];
        end
    end

    % Split based on choice
    if strcmp(split_type, 'byfile')
        train_files = data_files(1:2);
        test_file = data_files(3);

        data_test = load(fullfile('data', test_file.name));
        emg_test = preprocess_emg(data_test.emg, fs);
        labels_test = data_test.restimulus;

        Xtest = []; Ytest = [];
        for t = 1:step:(size(emg_test, 1) - window)
            win = emg_test(t:t+window-1, :);
            label = mode(labels_test(t:t+window-1));
            if label == 0, continue; end
            feats = extract_features(win);
            Xtest = [Xtest; feats];
            Ytest = [Ytest; label];
        end

        model = fitcensemble(X, Y);
    else
        cv = cvpartition(Y, 'HoldOut', 0.2);
        Xtrain = X(training(cv), :); Ytrain = Y(training(cv));
        Xtest = X(test(cv), :);     Ytest = Y(test(cv));
        model = fitcensemble(Xtrain, Ytrain);
    end

    % Predict and evaluate
    Ypred = predict(model, Xtest);
    acc = sum(Ypred == Ytest) / numel(Ytest) * 100;
    cm = confusionmat(Ytest, Ypred);

    % Just save results for later display
    save('models/trained_model.mat', 'model');
    save('models/test_data.mat', 'Xtest', 'Ytest', 'Ypred', 'cm', 'acc');

    % Don't show anything here!
end
