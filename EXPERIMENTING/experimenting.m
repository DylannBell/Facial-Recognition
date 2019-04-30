% Set number of training images to be 10
num_training_imgs = 5;

% Number of people (classes) in the set (3)
num_classes = 3;

% For simplicity sake just work with the first 3 directories
dir_name = 's1';

% Find number of images in folder (should be 10 - should all be the same)
num_total_imgs = size(dir([dir_name, '\*.pgm']), 1);

% Testing images 
num_testing_imgs = num_total_imgs - num_training_imgs;

% Create an empty Xi of zeros, this stores all the training data
X = zeros(50, num_training_imgs, num_classes);

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
    
    % Create the Wi for the 5 training images Wi : (q * pi)
    % What shall we call this variable? leaving it as Wi for now
    % not sure if this is best practise to just assign an empty matrix to 0's?
    Wi = zeros(50, num_training_imgs);

    for j = 1:num_training_imgs
        % Load the image and process it
        learning_img = imread(char(image_paths(j)));
        learning_img = process_img(learning_img);

        % Replace the ith column with the image
        % Load the 5 training images into Wi (need to change this to 
        % load into Xi after Wi.
        Wi(:,j) = learning_img;   
    end
    
    % Save the Wi in the Xi (which contains all the training data)
    X(:,:,i) = Wi;
    
end

% Load a testing image (6th image) and find it's hat value
testing_img = imread(char(image_paths(6)));
image_paths(6)
testing_img = process_img(testing_img);

yhat1 = find_yhat(testing_img, X(:,:,1));
yhat2 = find_yhat(testing_img, X(:,:,2));
yhat3 = find_yhat(testing_img, X(:,:,3));

dist1 = norm(testing_img - yhat1)
dist2 = norm(testing_img - yhat2)
dist3 = norm(testing_img - yhat3)

% Process image
function img = process_img(img)
    % Values for the downscaling
    C = 10;
    D = 5;

    % Image is already grayscale, should we check if it is or should we
    % assume all files are going to be .pgm?
    
    % Downscale image into c x d
    img = imresize(img, [C, D]);
    
    % Column concatenate the image so it's of size q * 1 (q = c x d)
    q = C * D;
    img = reshape(img, q, 1);
    img = double(img);
    
    % Normalise the image between 0 and 1
    img = img / max(img);
end

function yhat = find_yhat(img, Wi)
    % Algorithm to find Bhati is (XiT * Xi)^-1 * XiT * y
    % y = img
    % Xi is each class (Wi)
    % Since we only one class atm : Xi = Wi
    bhat = inv(transpose(Wi) * Wi) * transpose(Wi) * img;
    
    % Find yhat
    yhat = Wi * bhat;
end
