function gestureRecognitionGUI()
    f = figure('Name', 'EMG Gesture Recognition', 'Position', [500 300 600 400]);

    % Buttons (positions reordered)
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Train Model', ...
        'Position', [50 300 120 40], 'Callback', @train_model_callback);

    uicontrol(f, 'Style', 'pushbutton', 'String', 'Load Sample', ...
        'Position', [50 240 120 40], 'Callback', @load_sample);

    uicontrol(f, 'Style', 'pushbutton', 'String', 'Simulate', ...
        'Position', [50 180 120 40], 'Callback', @simulate_callback);

    % Larger text area for output
    txt = uicontrol(f, 'Style', 'text', 'Position', [200 50 370 300], ...
        'HorizontalAlignment', 'left', 'FontSize', 10, ...
        'BackgroundColor', 'white', 'Max', 10);

    function load_sample(~, ~)
        [file, path] = uigetfile('data/*.mat');
        if isequal(file, 0)
            return;
        end
        data = load(fullfile(path, file));
        assignin('base', 'current_data', data);
        set(txt, 'String', sprintf('Loaded: %s', file));
    end

    function train_model_callback(~, ~)
        % Use only file split
        split_type = 'byfile';
        train_model(split_type);
        set(txt, 'String', sprintf('Model Trained using: %s', split_type));
    end

    function simulate_callback(~, ~)
        data = evalin('base', 'current_data');
        fs = 2000;

        if ~exist('models/trained_model.mat', 'file')
            set(txt, 'String', 'Model not found. Train first.');
            return;
        end

        emg = preprocess_emg(data.emg, fs);
        labels = data.restimulus;

        load('models/trained_model.mat', 'model');

        window = round(0.2 * fs);
        step = round(0.1 * fs);
        output = '';
        for t = 1:step:(size(emg, 1) - window)
            true_label = mode(labels(t:t+window-1));
            if true_label == 0, continue; end
            feats = extract_features(emg(t:t+window-1, :));
            pred_label = predict(model, feats);
            true_gesture = label_to_gesture(true_label);
            pred_gesture = label_to_gesture(pred_label);
            output = sprintf('True: %d (%s) | Pred: %d (%s)\n%s', ...
                true_label, true_gesture, pred_label, pred_gesture, output);
            set(txt, 'String', output);
            pause(0.1);
        end
    end
end

% Helper function to map labels to gesture names
function name = label_to_gesture(label)
    gestures = { ...
        'Rest', 'Thumb Flex', 'Index Flex', 'Middle Flex', ...
        'Ring Flex', 'Little Flex', 'Wrist Ext', 'Wrist Flex', ...
        'Hand Open', 'Hand Close', 'Pinch', 'Grasp' ...
    };
    if label >= 1 && label <= numel(gestures)
        name = gestures{label};
    else
        name = 'Unknown';
    end
end
