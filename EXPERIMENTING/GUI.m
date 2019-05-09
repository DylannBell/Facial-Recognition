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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% Populate training set with face data set
function training_data = learn_faces(directory_path, training_data, num_total_imgs, num_training_imgs, num_classes, q, c, d)
    for i = 1:num_classes
        % Keep an array of all file names and image paths (training + learning)
        image_paths = strings(1, num_total_imgs);

        dir_name = strcat('s', num2str(i));

        % Loop through all images and save image paths into an array
        for j = 1:num_total_imgs
            fileName = strcat(num2str(j), '.pgm');
            path = strcat(directory_path, '\', dir_name, '\', fileName)
            image_paths(1, j) = path;
        end
        
        
    end

% SET CONSTANTS FOR GUI ENVIRONMENT
% A number of constants need to be saved and readily available to functions
% throughout this system, therefore add it as a field to handles
% Access constants like so - handles.constants('num_training_imgs') 
function handles = set_constants(handles, hObject)
    keySet = {
                'num_training_imgs', 
                'num_training_classes', 
                'num_testing_classes',
                'num_total_imgs',
                'c',
                'd',
                'q'
               };
    valueSet = {5, 10, 10, 10, 10, 5, 50};
    constants = containers.Map(keySet, valueSet);
    handles.constants = constants;  
    guidata(hObject, handles);  
    
% OPEN DIRECTORY BUTTON
% Allows users to navigate to some directory where the system will 
% automatically traverse some expected directory stucture for training and
% testing images
function pushbutton1_Callback(hObject, eventdata, handles)
    % initialise environment
    handles = set_constants(handles, hObject);
    
    % open folder selection dialog box and save path
    testing_directory_path = uigetdir()
    dir_content = dir(directory_path);
    num_testing_classes = sum([dir_content.isdir]) - 2;
    handles.constants('num_testing_classes') = num_testing_classes;
    
    % determine the no. of classes by counting the number of sub folders in
    % dir
    dir_content = dir(directory_path);
    num_folders = sum([dir_content.isdir]) - 2;
    handles.constants('num_classes') = num_folders;
    
    % Initialise + Populate training data matrix
    %training_data = zeros(handles.constants('q'), handles.constants('num_training_imgs'), handles.constants('num_classes'));
    %training_data = learn_faces(directory_path, training_data, handles.constants('num_total_imgs'), handles.constants('num_training_imgs'), handles.constants('num_classes'), handles.constants('q'), handles.constants('c'), handles.constants('d'));
    