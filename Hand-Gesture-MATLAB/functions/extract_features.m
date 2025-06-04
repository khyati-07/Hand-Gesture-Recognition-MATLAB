function features = extract_features(win)
    % win: [samples x channels]
    % Features: MAV, ZC, SSC, WL, VAR

    mav = mean(abs(win));
    var_feat = var(win);
    wl = sum(abs(diff(win)));
    ssc = sum(diff(sign(diff(win))) ~= 0);
    zc = sum(diff(sign(win)) ~= 0);

    features = [mav, var_feat, wl, ssc, zc];
end
