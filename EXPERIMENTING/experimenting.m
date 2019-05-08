% Set number of training images to be 10
num_training_imgs = 5;

% Number of people (classes) in the set (3)
num_classes = 3;

% Find number of images in folder (should be 10 - should all be the same)
num_total_imgs = size(dir(['s1', '\*.pgm']), 1);

% Values for the downscaling
c = 10;
d = 5;
q = c * d;

% Create an empty training data matrix of zeros (X)
training_data = zeros(q, num_training_imgs, num_classes);

%%% TRAINING %%%
% Populate training data matrix
training_data = learn_faces(training_data, num_total_imgs, num_training_imgs, num_classes, q, c, d);


%%%% TESTING %%%
% Load the testing directory and create image_paths
testing_dir = uigetdir();
num_testing_imgs = size(dir([testing_dir, '\*.pgm']), 1);
testing_image_paths = strings(1, num_total_imgs);


% Loop through all testing images and save image paths into an array
for j = 1:num_testing_imgs
    fileName = strcat(num2str(j), '.pgm');
    path = strcat(testing_dir, '/', fileName);
    testing_image_paths(1, j) = path;
end

% Load testing images
for i = 1:num_testing_imgs
    testing_img = imread(char(testing_image_paths(i)));
    testing_img = process_img(testing_img, q, c, d);

    % Create a hats matrix to store all the hat values
    hats = zeros(num_classes, 1);

    for j = 1:num_classes
        hat = find_yhat(testing_img, training_data(:,:,j));
        dist = norm(testing_img - hat);
        hats(j) = dist;
    end

    fprintf("Image " + i + ": ");
    [value, index] = min(hats);
    fprintf("This is from class " + index + "\n");
end

function yhat = find_yhat(img, Xi)
    % Algorithm to find bhat is (XiT * Xi)^-1 * XiT * y
    % y = img
    % yhat = Xi * bhat
    yhat = Xi * ((transpose(Xi) * Xi)\transpose(Xi) * img);
end

% Populate training set with face data set
function training_data = learn_faces(training_data, num_total_imgs, num_training_imgs, num_classes, q, c, d)
    for i = 1:num_classes
        % Keep an array of all file names and image paths (training + learning)
        image_paths = strings(1, num_total_imgs);

        dir_name = strcat('s', num2str(i));

        % Loop through all images and save image paths into an array
        for j = 1:num_total_imgs
            fileName = strcat(num2str(j), '.pgm');
            path = strcat(dir_name, '/', fileName);
            image_paths(1, j) = path;
        end

        % Create the Xi for the 5 training images Xi : (q * pi)
        Xi = zeros(50, num_training_imgs);

        for j = 1:num_training_imgs
            % Load the image and process it
            training_img = imread(char(image_paths(j)));
            training_img = process_img(training_img, q, c, d);

            % Replace the ith column with the image
            % Load the 5 training images into Wi (need to change this to 
            % load into Xi after Wi.
            Xi(:,j) = training_img;   
        end

        % Save the Wi in the Xi (which contains all the training data)
        training_data(:,:,i) = Xi;

    end
end

% Process image
function img = process_img(img, q, c, d)
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
end


