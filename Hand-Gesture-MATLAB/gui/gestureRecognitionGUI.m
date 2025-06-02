% gestureRecognitionGUI.m
% GUI for EMG Gesture Recognition

function gestureRecognitionGUI()
    % Create GUI figure
    f = figure('Name', 'EMG Gesture Recognition', 'NumberTitle', 'off', ...
               'Position', [500, 300, 400, 300]);
    
    % Start Camera Button
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Start Camera', ...
              'Position', [150, 200, 100, 40], 'Callback', @startCamera);
    
    % Exit Button
    uicontrol(f, 'Style', 'pushbutton', 'String', 'Exit', ...
              'Position', [150, 140, 100, 40], 'Callback', 'close(gcf)');
    
    % Callback function for Start Camera
    function startCamera(~, ~)
        % Initialize webcam
        cam = webcam;
        h = figure;
        while ishandle(h)
            img = snapshot(cam);
            imshow(img);
            title('Live Camera - Press Ctrl+C to stop');
            drawnow;
        end
        clear cam;
    end
end
