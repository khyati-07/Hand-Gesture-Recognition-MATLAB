function test_model(test_filename)
    fs = 2000;

    loaded = load('models/trained_model.mat');
    model = loaded.model;

    data_test = load(test_filename);
    emg_test = preprocess_emg(data_test.emg, fs);
    labels_test = data_test.restimulus;

    window = round(0.2 * fs);
    step = round(0.1 * fs);

    Xtest = []; Ytest = [];
    for t = 1:step:(size(emg_test,1) - window)
        win = emg_test(t:t+window-1, :);
        label = mode(labels_test(t:t+window-1));
        if label == 0, continue; end
        feats = extract_features(win);
        Xtest = [Xtest; feats];
        Ytest = [Ytest; label];
    end

    Ypred = predict(model, Xtest);

    acc = sum(Ypred == Ytest) / numel(Ytest) * 100;
    cm = confusionmat(Ytest, Ypred);

    fprintf('Test accuracy on %s: %.2f%%\n', test_filename, acc);

    save('models/test_data.mat', 'Xtest', 'Ytest', 'Ypred', 'cm');

    show_confusion(Ytest, Ypred);
end
