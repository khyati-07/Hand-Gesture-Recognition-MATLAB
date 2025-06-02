% train_model.m
% Train a classifier using extracted features

function model = train_model(features, labels)
    % Train a multiclass SVM classifier
    model = fitcecoc(features, labels);
    
    % Save the trained model
    save('models/trained_model.mat', 'model');
end
