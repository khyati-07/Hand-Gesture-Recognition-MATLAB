function simulate(txt)
    data = evalin('base', 'current_data');
    fs = 2000;

    emg = preprocess_emg(data.emg, fs);
    labels = data.restimulus;

    window = round(0.2 * fs);
    step = round(0.1 * fs);

    output = '';
    for t = 1:step:(size(emg,1)-window)
        label_window = labels(t:t+window-1);
        if std(label_window) > 0, continue; end  % skip unstable labels
        true_label = mode(label_window);
        if true_label == 0, continue; end

        pred_label = predict_gesture(emg(t:t+window-1, :));
        output = sprintf('True: %d | Predicted: %d\n%s', true_label, pred_label, output);
        set(txt, 'String', output);
        pause(0.1);
    end
end
