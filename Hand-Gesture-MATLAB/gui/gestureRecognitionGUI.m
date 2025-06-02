
function gestureRecognitionGUI()
    fig = figure('Name', 'EMG Gesture Recognition', 'Position', [500 300 400 300]);

    % Train Model Button
    uicontrol('Style', 'pushbutton', 'String', 'Train Model', ...
        'Position', [150 220 100 30], 'Callback', @trainCallback);

    % Load Sample Button
    uicontrol('Style', 'pushbutton', 'String', 'Load Sample', ...
        'Position', [150 170 100 30], 'Callback', @loadSampleCallback);

    % Predict Button
    uicontrol('Style', 'pushbutton', 'String', 'Predict', ...
        'Position', [150 120 100 30], 'Callback', @predictCallback);

    % Exit Button
    uicontrol('Style', 'pushbutton', 'String', 'Exit', ...
        'Position', [150 70 100 30], 'Callback', @(~,~) close(fig));

    % Prediction Display
    uicontrol('Style', 'text', 'String', 'Prediction: None', ...
        'Position', [100 30 200 20], 'Tag', 'predictionLabel');

    assignin('base', 'currentSample', []);
end



function trainCallback(~, ~)
    train_model();  % Calls your function
    msgbox('Model trained and saved to models/trained_model.mat');
end

function loadSampleCallback(~, ~)
    data = load(fullfile('data', 'S1_A1_E1.mat'));
    X = data.emg;
    idx = randi(size(X, 1));
    sample = X(idx, :);
    assignin('base', 'currentSample', sample);
    msgbox('Random EMG sample loaded into memory.');
end

function predictCallback(~, ~)
    sample = evalin('base', 'currentSample');
    if isempty(sample)
        errordlg('Please load a sample first.');
        return;
    end

    prediction = predict_gesture(sample);

    % Update GUI
    label = findall(gcf, 'Tag', 'predictionLabel');
    set(label, 'String', ['Prediction: ', num2str(prediction)]);
end
