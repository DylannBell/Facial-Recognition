% for simplicities sake just work with the s1 directory
dir_name = 's1';

% find num of images in folder
num_training_imgs= size(dir([dir_name, '\*.pgm']), 1);

% keep an array of file names and image paths
image_paths = strings(1, num_training_imgs);

% loop through and save image paths into an array
for i = 1:num_training_imgs
    fileName = strcat(num2str(i), '.pgm');
    path = strcat(dir_name, '/', fileName);
    image_paths(1, i) = path;
end

% do stuff
testing_img_1 = imread(char(image_paths(1)));
process_img(testing_img_1);

% process image
function processed_img = process_img(img)
    % convert to greyscale
    
    % downsample image into c x d
    
    % normalise the image between 0 and 1
    
    % column concatenate the image so it's of size q * 1 (q = c x d)
    
end


