function varargout = GUI(varargin)

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
                'q',
                'total_counter',
                'correct_counter'
               };
    valueSet = {
                  handles.popupmenu1.Value,
                  10-handles.popupmenu1.Value,
                  0,
                  0,
                  10,
                  10,
                  5,
                  50,
                  0,
                  0
               };
    
    % create a key-value pair by mapping keySet + valueSet
    constants = containers.Map(keySet, valueSet);
    handles.constants = constants;  
    guidata(hObject, handles);  


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)

    % Choose default command line output for GUI
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    % remove graph axis from GUI
    set(handles.axes1, 'visible', 'off')
    set(handles.axes2, 'visible', 'off')
    
    % default pop up to 5
    handles.popupmenu1.Value = 5;
    
    % UIWAIT makes GUI wait for user response (see UIRESUME)
    % uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles)
    varargout{1} = handles.output;


% Process image according to the paper
function img = process_img(img, handles)

    % Load constants from handles
    q = handles.constants('q');
    c = handles.constants('c');
    d = handles.constants('d');
    
    % Convert to grayscale if needed
    if ndims(img) == 3
        img = rgb2gray(img);
    end
    
    % Downscale image into c x d
    img = imresize(img, [c, d]);
    
    % Column concatenate the image so it's of size q * 1 (q = c x d)
    d = c * d;
    img = reshape(img, d, 1);
    img = double(img);
    
    % Normalise the image between 0 and 1
    img = img / max(img);

% Function which contains the logic to train model
% Images are automatically taken from Training directory
% Populate training set with face data set
function training_data = learn_faces(handles)

    % Load constants from handles
    num_training_classes = handles.constants('num_training_classes');
    num_training_imgs = handles.constants('num_training_imgs');
    q = handles.constants('q');
    
    % Initialise the training data matrix (X)
    training_data = zeros(q, num_training_imgs, num_training_classes);
    
    % Load 
    training_dir = dir("Training");
    
    for i = 1:num_training_classes
        
        % Keep an array of all file names and image paths for training data
        image_paths = strings(1, num_training_imgs);
        dir_name = training_dir(i+2).name;
        
        % Loop through all images and save image paths into an array
        for j = 1:num_training_imgs
            current_dir = dir("Training/" + dir_name);
            fileName = current_dir(j+2).name;
            path = strcat("Training/", dir_name, "/", fileName);
            image_paths(1, j) = path;
        end

        % Initialise the class_layer for the 5 training images Xi : (q * pi)
        class_layer = zeros(50, num_training_imgs);
        
        % For each image in the training images class
        for k = 1:num_training_imgs
            
            % Load the image and process it
            training_img = imread(char(image_paths(k)));           
            training_img = process_img(training_img, handles);
            
            % Replace the ith column with the image
            % Load the 5 training images into Wi (need to change this to 
            % load into Xi after Wi.
            class_layer(:,k) = training_img;   
        end

        % Save the Wi in the Xi (which contains all the training data)
        training_data(:,:,i) = class_layer;
    end    

% Algorithm to find bhat is (XiT * Xi)^-1 * XiT * y
% y = img
% yhat = Xi * bhat
function yhat = find_yhat(img, Xi)
    yhat = Xi * ((transpose(Xi) * Xi)\transpose(Xi) * img);

% Function which tests images against the training data
% Will automatically process images from a directory specified by the user
function test_faces(handles, testing_dir_path, training_data)

    % Load constands from handles
    num_testing_imgs = handles.constants('num_testing_imgs');
    num_training_imgs = handles.constants('num_training_imgs');
    num_total_imgs = handles.constants('num_total_imgs');
    num_testing_classes = handles.constants('num_testing_classes');
    num_training_classes = handles.constants('num_training_classes');
    
    % Load Training and Testing directories
    training_dir = dir("Training");
    testing_dir = dir(testing_dir_path);
    
    for i = 1:num_testing_classes
        
        % Keep an array of all file names and image paths for training data
        testing_image_paths = strings(1, num_total_imgs);
        class_testing_dir = testing_dir(i+2).name;
        
        % Loop through all images and save image paths into an array
        for j = 1:num_total_imgs
            current_dir = dir(strcat(testing_dir_path, '/', class_testing_dir));
            fileName = current_dir(j+2).name;
            path = strcat(testing_dir_path, '/', class_testing_dir, '/', fileName);
            testing_image_paths(1, j) = path;
        end
        
        % Load testing images
        for k = num_training_imgs+1:num_total_imgs
            testing_img = imread(char(testing_image_paths(k)));
            
            % Display testing image on LHS
            imshow(testing_img, 'Parent', handles.axes1);
            pause(0.2)
            
            testing_img = process_img(testing_img, handles);

            % Initialise a hats matrix to store all the hat values
            hats = zeros(num_training_classes, 1);

            for m = 1:num_training_classes
                hat = find_yhat(testing_img, training_data(:,:,m));
                dist = norm(testing_img - hat);
                hats(m) = dist;
            end
            
            % find min Y-Hat distance
            [min_value, min_index] = min(hats);
            
            display_correct_image(handles, hats, training_dir);
            display_recognition_accuracy(handles, training_dir, class_testing_dir, min_index);
             
        end
    end
    
% Display the correct correct in the RHS axis
function display_correct_image(handles, hats, training_dir)
    % find minimum Y-Hat value   
    [min_value, min_index] = min(hats);
    
    % Display Correct Image
    correct_img_path = "Training/" + training_dir(min_index+2).name;
    correct_img_dir = dir(correct_img_path);
    correct_img_name = correct_img_dir(3).name;
    correct_img = imread(strcat(correct_img_path, '/', correct_img_name));
    imshow(correct_img, 'Parent', handles.axes2);

    % Display Y-Hat Value
    handles.text7.String = min_value;

    
% Display the recognition accuracy
function display_recognition_accuracy(handles, training_dir, class_testing_dir, min_index)
    
    % total no. of images
    total_counter = handles.constants('total_counter');
    
    % total no. of correctly identified images
    correct_counter = handles.constants('correct_counter');

    total_counter = total_counter + 1;

    % if the matched training image is from the same directory as the
    % testing image - increment the correct counter
    if strcmp(training_dir(min_index+2).name, class_testing_dir)
        correct_counter = correct_counter + 1;
    end

    handles.text8.String = num2str(correct_counter/total_counter * 100);

    % append accuracy
    handles.constants('total_counter') = total_counter;
    handles.constants('correct_counter') = correct_counter;

    pause(0.2);
    
    
    
    
% OPEN DIRECTORY BUTTON
% Allows users to navigate to some directory where the system will 
% automatically traverse some expected directory stucture for training and
% testing images
function pushbutton1_Callback(hObject, eventdata, handles)

    % Initialise constants
    handles = set_constants(handles, hObject);

    % Open folder selection dialog box and save testing path
    % Catch Error if no directory is chosen
    testing_dir = uigetdir();
    
    % Exit if no file chosen
    if testing_dir == 0
        handles.exit = true;
        guidata(hObject, handles);
        return
    end
    
    %%% TRAINING %%%%
    % Load the training path and all subfolders into matlab
    addpath(genpath("Training"));
    
    % Determine number of classes by counting the directories
    training_dir = dir("Training");
    num_training_classes = sum([training_dir.isdir]) - 2;
    handles.constants('num_training_classes') = num_training_classes;
    
    % This finds number of total images in first dir (assume all are the
    % same)
    handles.constants('num_total_imgs') = size(dir(['Training\s1', '\']), 1)-2;
    
    
    % Initialise + Populate training data matrix
    training_data = learn_faces(handles);
    
    %%% TESTING %%%
    % Count number of sub directories in testing dir
    testing_dir_content = dir(testing_dir);
    num_testing_classes = sum([testing_dir_content.isdir]) - 2;
    handles.constants('num_testing_classes') = num_testing_classes;
    
    % Test data
    test_faces(handles, testing_dir, training_data);
    

    
% Y-Hat display window
function text7_CreateFcn(hObject, eventdata, handles)

% Allows the user to input the number of training images - e.g. defines the
% number of images to be used during training
function popupmenu1_Callback(hObject, eventdata, handles)

function popupmenu1_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
