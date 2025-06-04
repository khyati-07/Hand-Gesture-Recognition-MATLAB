function show_confusion(Ytrue, Ypred)
    figure;
    cm = confusionmat(Ytrue, Ypred);
    confusionchart(cm, 'Title', 'Confusion Matrix', ...
        'RowSummary','row-normalized', ...
        'ColumnSummary','column-normalized');
end
