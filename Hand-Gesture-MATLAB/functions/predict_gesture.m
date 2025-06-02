% predict_gesture.m
% Predict gesture from EMG data using the trained model

function predicted_label = predict_gesture(emg_sample)
    % Load the trained model
    load('models/trained_model.mat', 'model');
    
    % Feature extraction: Mean Absolute Value (MAV)
    mav = mean(abs(emg_sample));
    
    % Predict gesture
    predicted_label = predict(model, mav);
end
