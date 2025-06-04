function label = predict_gesture(emg_window)
    load('models/trained_model.mat', 'model');
    feats = extract_features(emg_window);
    label = predict(model, feats);
end
