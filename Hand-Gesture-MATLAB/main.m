clc;
clear;
close all;

% Set current folder to the root of the project
projectRoot = fileparts(mfilename('fullpath'));
cd(projectRoot);

% Add paths to subfolders
addpath(fullfile(projectRoot, 'functions'));
addpath(fullfile(projectRoot, 'gui'));
addpath(fullfile(projectRoot, 'models'));
addpath(fullfile(projectRoot, 'data'));

gestureRecognitionGUI();  % Start GUI
