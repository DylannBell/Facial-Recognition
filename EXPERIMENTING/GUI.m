function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 08-May-2019 20:04:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% SET CONSTANTS FOR GUI ENVIRONMENT
% A number of constants need to be saved and readily available to functions
% throughout this system, therefore add it as a field to handles
% Access constants like so - handles.constants('num_training_imgs') 
function handles = set_constants(handles, hObject)
    keySet = {
                'num_training_imgs',
                'num_testing_imgs',
                'num_training_classes', 
                'num_testing_classes',
                'num_total_imgs',
                'c',
                'd',
                'q'
               };
    valueSet = {5, 5, 10, 10, 10, 10, 5, 50};
    constants = containers.Map(keySet, valueSet);
    handles.constants = constants;  
    guidata(hObject, handles);  


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% Process image
function img = process_img(img, handles)
    q = handles.constants('q');
    c = handles.constants('c');
    d = handles.constants('d');
    
    % Image is already grayscale, should we check if it is or should we
    % assume all files are going to be .pgm?
    
    % Downscale image into c x d
    img = imresize(img, [c, d]);
    
    % Column concatenate the image so it's of size q * 1 (q = c x d)
    d = c * d;
    img = reshape(img, d, 1);
    img = double(img);
    
    % Normalise the image between 0 and 1
    img = img / max(img);


% Populate training set with face data set
function training_data = learn_faces(handles)

    training_data = zeros(handles.constants('q'), handles.constants('num_training_imgs'), handles.constants('num_training_classes'));
    num_training_classes = handles.constants('num_training_classes');
    num_training_imgs = handles.constants('num_training_imgs');
    
    for i = 1:num_training_classes
        
        % Keep an array of all file names and image paths for training data
        image_paths = strings(1, num_training_imgs);

        dir_name = strcat('s', num2str(i));

        % Loop through all images and save image paths into an array
        for j = 1:num_training_imgs
            fileName = strcat(num2str(j), '.pgm');
            path = strcat(dir_name, '/', fileName);
            image_paths(1, j) = path;
        end

        % Initialise the class_layer for the 5 training images Xi : (q * pi)
        class_layer = zeros(50, num_training_imgs);
           
        for j = 1:num_training_imgs
            % Load the image and process it
            training_img = imread(char(image_paths(j)));
            training_img = process_img(training_img, handles);

            % Replace the ith column with the image
            % Load the 5 training images into Wi (need to change this to 
            % load into Xi after Wi.
            class_layer(:,j) = training_img;   
        end

        % Save the Wi in the Xi (which contains all the training data)
        training_data(:,:,i) = class_layer;
    end    

%
function yhat = find_yhat(img, Xi)
    % Algorithm to find bhat is (XiT * Xi)^-1 * XiT * y
    % y = img
    % yhat = Xi * bhat
    yhat = Xi * ((transpose(Xi) * Xi)\transpose(Xi) * img);


function test_faces(handles, testing_dir_path, training_data)

    num_testing_imgs = handles.constants('num_testing_imgs');
    num_total_imgs = handles.constants('num_total_imgs');
    num_testing_classes = handles.constants('num_testing_classes');
    
    testing_dir = dir(testing_dir_path);
    
    for i = 1:num_testing_classes
        
        % Initialise testing image paths
        testing_image_paths = strings(1, num_testing_imgs);
        
        % Keep an array of all file names and image paths for training data
        testing_image_paths = strings(1, num_testing_imgs);
        
        % NEED TO CHANGE THIS TO BE S
        %class_testing_dir = strcat('s', num2str(i));
        class_testing_dir = testing_dir(i+2).name;

        % Loop through all images and save image paths into an array
        for j = 1:num_total_imgs
            fileName = strcat(num2str(j), '.pgm');
            path = strcat(testing_dir_path, '/', class_testing_dir, '/', fileName);
            testing_image_paths(1, j) = path;
        end
        
        % Load testing images
        for k = num_testing_imgs+1:num_total_imgs
            testing_img = imread(char(testing_image_paths(k)));
            testing_img = process_img(testing_img, handles);

            % Initialise a hats matrix to store all the hat values
            hats = zeros(num_testing_classes, 1);

            for m = 1:num_testing_classes
                hat = find_yhat(testing_img, training_data(:,:,m));
                dist = norm(testing_img - hat);
                hats(m) = dist;
            end
            
            % Obtain where current photo is from
            current_class_int = str2num(class_testing_dir(2));
            fprintf("Class: " + current_class_int + ", Image: " + k);
            
            [min_value, min_index] = min(hats);
            fprintf("Index = " + min_index + "\n"); 
            
            
            
           
        end
    end
    
% OPEN DIRECTORY BUTTON
% Allows users to navigate to some directory where the system will 
% automatically traverse some expected directory stucture for training and
% testing images
function pushbutton1_Callback(hObject, eventdata, handles)
    % initialise environment
    handles = set_constants(handles, hObject);
    

    %%% TRAINING %%%%
    
    % Determine number of classes by counting the directories
    training_dir = dir("Training");
    num_training_classes = sum([training_dir.isdir]) - 2;
    handles.constants('num_training_classes') = num_training_classes;
    
    % This finds number of total images in first dir (assume all are the
    % same)
    handles.constants('num_total_imgs') = size(dir(['Training\s1', '\*.pgm']), 1);
    
    
    % Initialise + Populate training data matrix
    training_data = learn_faces(handles);
    
    
    
    
    %%% TESTING %%%
   
    % Open folder selection dialog box and save testing path
    testing_dir = uigetdir()
    
    % Count number of sub directories in testing dir
    testing_dir_content = dir(testing_dir);
    num_testing_classes = sum([testing_dir_content.isdir]) - 2;
    handles.constants('num_testing_classes') = num_testing_classes;
    
    % Test data
    test_faces(handles, testing_dir, training_data)
    

    
    