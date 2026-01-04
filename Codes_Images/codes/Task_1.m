%% Task 1 Basic Image Manipulation

% Read the DICOM image and information
info = dicominfo('CT11.dcm');
disp(info)
ct = double(dicomread(info));

% Convert to Hounsfield Units
slope = double(info.RescaleSlope);
intercept = double(info.RescaleIntercept);
hu = ct * slope + intercept;

% Choose display window
window_center = 50;
window_width = 400;

% Apply windowing
min_w = window_center - window_width/2;
max_w = window_center + window_width/2;
hu_windowed = (hu - min_w) / (max_w - min_w);
hu_windowed = max(min(hu_windowed, 1), 0);

% Convert to 8-bit for saving and display
hu_uint8 = uint8(hu_windowed * 255);

% Save the windowed image as PNG
imwrite(hu_uint8, 'CT11_windowed.png');

% Display raw and windowed images side by side
figure
subplot(1,2,1)
imshow(hu, [])
title('Raw CT Image (before windowing)')

subplot(1,2,2)
imshow(hu_uint8, [])
title('Windowed CT Image (after windowing)')

% Enlarge the image by 1.5 using bicubic interpolation
im_enlarged = imresize(hu_uint8, 1.5, 'bicubic');

% Save the enlarged image as a TIFF file
imwrite(im_enlarged, 'CT11_enlarged_1p5x_bicubic.tif');

% Rotate the enlarged image by 90 degrees using bicubic interpolation
im_rotated = imrotate(im_enlarged, 90, 'bicubic', 'loose');

% Save the rotated image as a separate TIFF file
imwrite(im_rotated, 'CT11_enlarged_1p5x_rotated_90deg_bicubic.tif');

% Display enlarged and rotated images side by side
figure
subplot(1,2,1)
imshow(im_enlarged, [])
title('Enlarged Image (1.5x)')

subplot(1,2,2)
imshow(im_rotated, [])
title('Rotated Image (after 1.5x enlargement)')

% Display original and final rotated images side by side
figure
subplot(1,3,1)
imshow(hu, [])
title('Raw CT image')

subplot(1,3,2)
imshow(hu_uint8, [])
title('Original Windowed Image')

subplot(1,3,3)
imshow(im_rotated, [])
title('Final Rotated Image (1.5x enlarged + 90° rotated)')

%% Task 2 - Histogram Analysis

% Read the image
img_xray_14 = imread('X-Ray_14.jpg');

% Check if the image is RGB, convert to grayscale if necessary
if ndims(img_xray_14) == 3
    img_xray_14 = rgb2gray(img_xray_14);
end

% Perform histogram equalisation
img_xray_14_eq = histeq(img_xray_14);

% Save equalised image
imwrite(img_xray_14_eq, 'X-Ray_14_histeq.png');

% Show histograms side by side
figure
subplot(1,2,1)
[counts_orig, bins_orig] = imhist(img_xray_14);
bar(bins_orig, counts_orig)
title('Original Histogram')
xlabel('Pixel Intensity')
ylabel('Number of Pixels')
axis([0 255 0 max(counts_orig)*1.1])  % add extra space on top
grid on

subplot(1,2,2)
[counts_eq, bins_eq] = imhist(img_xray_14_eq);
bar(bins_eq, counts_eq)
title('Equalised Histogram')
xlabel('Pixel Intensity')
ylabel('Number of Pixels')
axis([0 255 0 max(counts_eq)*1.1])  % add extra space on top
grid on

% Show original and equalised images side by side
figure
subplot(1,2,1)
imshow(img_xray_14, [])
title('Original Image')

subplot(1,2,2)
imshow(img_xray_14_eq, [])
title('Histogram Equalised Image')



%% Task 3 High and Low Pass Mask/Kernel Filtering

% Read the image and ensure grayscale format
img_mri_8 = imread('MRI_8.jpg');
if ndims(img_mri_8) == 3
    img_mri_8 = rgb2gray(img_mri_8);
end

% Low Pass Filters

% Average filter with 5x5 kernel for smoothing
h_avg = fspecial('average', [5 5]);
lp_avg = imfilter(img_mri_8, h_avg, 'replicate');

% Gaussian filter with sigma 1.0 for moderate smoothing
h_gauss = fspecial('gaussian', [5 5], 1.0);
lp_gauss = imfilter(img_mri_8, h_gauss, 'replicate');

% Median filter with 5x5 kernel 
lp_median = medfilt2(img_mri_8, [5 5]);

% High Pass Filters

% Laplacian filter with alpha 0.2 for edge detection
h_lap = fspecial('laplacian', 0.2);
hp_lap = imfilter(img_mri_8, h_lap, 'replicate');
hp_lap_out = uint8(255 * mat2gray(hp_lap));

% Prewitt filter for edge detection using gradient magnitude
h_prewitt = fspecial('prewitt');
gx_prewitt = imfilter(img_mri_8, h_prewitt, 'replicate');
gy_prewitt = imfilter(img_mri_8, h_prewitt', 'replicate');
hp_prewitt_mag = sqrt(double(gx_prewitt).^2 + double(gy_prewitt).^2);
hp_prewitt_out = uint8(255 * mat2gray(hp_prewitt_mag));

% Sobel filter for edge detection using gradient magnitude
h_sobel = fspecial('sobel');
gx_sobel = imfilter(img_mri_8, h_sobel, 'replicate');
gy_sobel = imfilter(img_mri_8, h_sobel', 'replicate');
hp_sobel_mag = sqrt(double(gx_sobel).^2 + double(gy_sobel).^2);
hp_sobel_out = uint8(255 * mat2gray(hp_sobel_mag));

% Write filtered images with clear names
imwrite(lp_avg,         'MRI_8_LP_average_5x5.jpg');
imwrite(lp_gauss,       'MRI_8_LP_gaussian_5x5_sigma1.jpg');
imwrite(lp_median,      'MRI_8_LP_median_5x5.jpg');
imwrite(hp_lap_out,     'MRI_8_HP_laplacian_alpha0p2.jpg');
imwrite(hp_prewitt_out, 'MRI_8_HP_prewitt_magnitude.jpg');
imwrite(hp_sobel_out,   'MRI_8_HP_sobel_magnitude.jpg');

% Display original and low pass results
figure
subplot(1,4,1), imshow(img_mri_8, []), title('Original')
subplot(1,4,2), imshow(lp_avg, []), title('Average 5x5')
subplot(1,4,3), imshow(lp_gauss, []), title('Gaussian 5x5 sigma=1')
subplot(1,4,4), imshow(lp_median, []), title('Median 5x5')

% Display original and high pass results
figure
subplot(1,4,1), imshow(img_mri_8, []), title('Original')
subplot(1,4,2), imshow(hp_lap_out, []), title('Laplacian alpha=0.2')
subplot(1,4,3), imshow(hp_prewitt_out, []), title('Prewitt')
subplot(1,4,4), imshow(hp_sobel_out, []), title('Sobel')


%% Task 4 Image Sharpening

% Image Sharpening with Different Parameter Settings

% Read the X-ray image
img_xray_14 = imread('X-ray_14.jpg');

% Check if the image is RGB, convert to grayscale if necessary
if ndims(img_xray_14) == 3
    img_xray_14 = rgb2gray(img_xray_14);
end

% Apply image sharpening with different parameter sets

% Strongly sharpened image 
img_sharp_strong = imsharpen(img_xray_14, 'Radius', 1.5, 'Amount', 2.0, 'Threshold', 0.0);

% Smoothly sharpened image 
img_sharp_smooth = imsharpen(img_xray_14, 'Radius', 1.0, 'Amount', 1.0, 'Threshold', 0.4);

% Balanced sharpened image 
img_sharp_balanced = imsharpen(img_xray_14, 'Radius', 1.2, 'Amount', 1.5, 'Threshold', 0.2);

% Save the balanced sharpened image as BMP file
imwrite(img_sharp_balanced, 'X-ray_14_sharpened_balanced_imsharpen.bmp');

% Display the three sharpened images for comparison
figure
subplot(1,3,1)
imshow(img_sharp_strong, [])
title('Strongly Sharpened Image')

subplot(1,3,2)
imshow(img_sharp_smooth, [])
title('Smoothly Sharpened Image')

subplot(1,3,3)
imshow(img_sharp_balanced, [])
title('Balanced Sharpened Image (Best Visuality)')

% Display the original and best (balanced) images side by side
figure
subplot(1,2,1)
imshow(img_xray_14, [])
title('Original X-ray Image')

subplot(1,2,2)
imshow(img_sharp_balanced, [])
title('Sharpened X-ray Image (Balanced)')

%% Noise Addition and Removal using Median Filter

% Read the MRI image
img_mri_8 = imread('MRI_8.jpg');

% Check if the image is RGB, convert to grayscale if necessary
if ndims(img_mri_8) == 3
    img_mri_8 = rgb2gray(img_mri_8);
end

% Apply salt and pepper noise with 0.09 noise density
img_mri_8_noisy = imnoise(img_mri_8, 'salt & pepper', 0.09);

% Save the noisy image as PNG 
imwrite(img_mri_8_noisy, 'MRI_8_noisy_saltpepper_0p09.png');

% Display the noisy image
figure
imshow(img_mri_8_noisy, [])
title('Noisy Image (Salt & Pepper, Density = 0.09)')

% Apply median filter to remove the noise
img_mri_8_denoised = medfilt2(img_mri_8_noisy, [3 3]);

% Save the de-noised image as PNG 
imwrite(img_mri_8_denoised, 'MRI_8_denoised_medianfilter.png');

% Display the de-noised image
figure
imshow(img_mri_8_denoised, [])
title('De-noised Image (Median Filter)')

% Display the original, noisy, and de-noised images side by side
figure
subplot(1,3,1)
imshow(img_mri_8, [])
title('Original MRI Image')

subplot(1,3,2)
imshow(img_mri_8_noisy, [])
title('Noisy Image (Salt & Pepper)')

subplot(1,3,3)
imshow(img_mri_8_denoised, [])
title('De-noised Image (Median Filter)')