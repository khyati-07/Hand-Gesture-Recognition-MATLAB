function prediction = predict_gesture(sample)
    if ~isfile('models/trained_model.mat')
        error('Trained model not found. Run training first.');
    end

    load('models/trained_model.mat', 'model');

    feat = extract_features(sample);
    prediction = predict(model, feat);
end
