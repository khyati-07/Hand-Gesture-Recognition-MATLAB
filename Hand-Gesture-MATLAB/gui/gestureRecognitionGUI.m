function gestureRecognitionGUI()
    f = figure('Name', 'EMG Gesture Recognition', 'Position', [500 300 700 450], ...
        'Color', [0.95 0.95 1]);

    % Title
    uicontrol(f, 'Style', 'text', 'String', 'EMG-Based Gesture Recognition', ...
        'Position', [200 390 300 40], 'FontSize', 14, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.8 0.85 1]);

    % Control Panel Box
    panel = uipanel(f, 'Title', 'Controls', 'FontSize', 11, ...
        'Position', [0.05 0.1 0.25 0.75]);

    % Buttons
    uicontrol(panel, 'Style', 'pushbutton', 'String', 'Train Model', ...
        'Units', 'normalized', 'Position', [0.2 0.75 0.6 0.15], ...
        'FontSize', 11, 'BackgroundColor', [0.6 0.8 1], 'Callback', @train_model_callback);

    uicontrol(panel, 'Style', 'pushbutton', 'String', 'Load Sample', ...
        'Units', 'normalized', 'Position', [0.2 0.5 0.6 0.15], ...
        'FontSize', 11, 'BackgroundColor', [0.7 1 0.7], 'Callback', @load_sample);

    uicontrol(panel, 'Style', 'pushbutton', 'String', 'Simulate', ...
        'Units', 'normalized', 'Position', [0.2 0.25 0.6 0.15], ...
        'FontSize', 11, 'BackgroundColor', [1 0.7 0.7], 'Callback', @simulate_callback);

    % Output text area
    uicontrol(f, 'Style', 'text', 'String', 'Output:', ...
        'Position', [250 330 60 20], 'FontWeight', 'bold', ...
        'BackgroundColor', [0.95 0.95 1]);

    txt = uicontrol(f, 'Style', 'text', 'Position', [250 140 420 180], ...
        'HorizontalAlignment', 'left', 'FontSize', 10, ...
        'BackgroundColor', 'white', 'Max', 2);

    % ==== Nested Functions ====

    function load_sample(~, ~)
        [file, path] = uigetfile('data/*.mat');
        if isequal(file, 0)
            return;
        end
        data = load(fullfile(path, file));
        assignin('base', 'current_data', data);
        assignin('base', 'current_filename', file);  % Save file name
        set(txt, 'String', sprintf('Loaded: %s', file));
    end

    function train_model_callback(~, ~)
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

        if ~exist('results', 'dir')
            mkdir('results');
        end

        % Use uploaded sample file name to generate result filename
        if evalin('base', 'exist(''current_filename'', ''var'')')
            loaded_filename = evalin('base', 'current_filename');
            [~, name, ~] = fileparts(loaded_filename);
            result_filename = sprintf('simulation_results_%s.txt', name);
        else
            result_filename = 'simulation_results_unknown.txt';
        end
        result_file = fullfile('results', result_filename);

        fid = fopen(result_file, 'w');

        output_lines = {};
        max_lines = 15;

        Ytest = [];
        Ypred = [];

        for t = 1:step:(size(emg, 1) - window)
            true_label = mode(labels(t:t+window-1));
            if true_label == 0, continue; end

            feats = extract_features(emg(t:t+window-1, :));
            pred_label = predict(model, feats);

            true_gesture = label_to_gesture(true_label);
            pred_gesture = label_to_gesture(pred_label);

            Ytest(end+1) = true_label; %#ok<AGROW>
            Ypred(end+1) = pred_label; %#ok<AGROW>

            line = sprintf('True: %d (%s) | Pred: %d (%s)', ...
                true_label, true_gesture, pred_label, pred_gesture);

            output_lines{end+1} = line;  %#ok<AGROW>
            fprintf(fid, '%s\n', line);

            recent_lines = output_lines(max(1, end - max_lines + 1):end);
            set(txt, 'String', sprintf('%s', strjoin(recent_lines, '\n')));
            pause(0.05);
        end
        fclose(fid);

        acc = sum(Ytest == Ypred) / numel(Ytest) * 100;
        cm = confusionmat(Ytest, Ypred);

        fprintf('\n========= Simulation Summary =========\n');
        fprintf('Accuracy: %.2f%%\n', acc);

        show_confusion(Ytest, Ypred);
        title(sprintf('Confusion Matrix (Accuracy: %.2f%%)', acc));

        output_lines{end+1} = sprintf('Simulation completed.\nResults saved in: %s', result_filename);
        set(txt, 'String', sprintf('%s', strjoin(output_lines(max(1, end - max_lines + 1):end), '\n')));
    end
end

function name = label_to_gesture(label)
    gestures = {
        'Rest', 'Thumb Flex', 'Index Flex', 'Middle Flex', 'Ring Flex', ...
        'Little Flex', 'Wrist Ext', 'Wrist Flex', 'Hand Open', 'Hand Close', ...
        'Pinch', 'Grasp', 'Point', 'Wave In', 'Wave Out', 'Thumb Up', ...
        'Thumb Down', 'OK Sign', 'Peace Sign', 'Rock', ...
        'Stop', 'Fist Bump', 'Call Me'
    };
    if label >= 1 && label <= numel(gestures)
        name = gestures{label};
    else
        name = 'Unknown';
    end
end
