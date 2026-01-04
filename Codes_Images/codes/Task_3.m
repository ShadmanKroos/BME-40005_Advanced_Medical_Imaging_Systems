%% Fourier Transform-Low Pass Filter

% Read image
img_xray = imread('X-ray_14.jpg');
if size(img_xray,3) == 3
    img_xray = rgb2gray(img_xray);
end
img_xray = im2double(img_xray);

% Fourier transform and shift
F = fft2(img_xray);
F = fftshift(F);

% Build Gaussian low pass filter
[M,N] = size(img_xray);
[u,v] = meshgrid(-floor(N/2):ceil(N/2)-1, -floor(M/2):ceil(M/2)-1);
sigma = 60;
H = exp(-((u.^2 + v.^2) / (2*sigma^2)));

% Apply filter in frequency domain
F_filt = F .* H;

% Inverse transform 
F_ishift = ifftshift(F_filt);
img_ifft = ifft2(F_ishift);
img_filtered = real(img_ifft);

% Show original image
figure
imshow(img_xray, [])
title('Original X-ray Image')

% Show Fourier Transform 
log_F = log(1 + abs(F));
figure
imshow(log_F, [])
title('Fourier Transform of X-ray Image')

% Show filtered Fourier Transform 
log_F_filt = log(1 + abs(F_filt));
figure
imshow(log_F_filt, [])
title('Filtered Fourier Transform (Gaussian LPF)')

% Show filtered image
figure
imshow(img_filtered, [])
title('Filtered X-ray Image (Gaussian Low Pass)')

%% Fourier Transform Noise Filter

% Read image
img_xray = imread('X-ray_14.jpg');
if size(img_xray,3) == 3
    img_xray = rgb2gray(img_xray);
end
img_xray = im2double(img_xray);

% Add periodic noise in vertical and horizontal directions
[M,N] = size(img_xray);
[X,Y] = meshgrid(0:N-1, 0:M-1);
amp_x = 0.08;              % amplitude of vertical stripe noise
amp_y = 0.08;              % amplitude of horizontal stripe noise
fx = 12;                   % cycles across image width (vertical stripes)
fy = 16;                   % cycles across image height (horizontal stripes)
noise = amp_x*sin(2*pi*fx*X/N) + amp_y*sin(2*pi*fy*Y/M);
img_noisy = img_xray + noise;
img_noisy = min(max(img_noisy,0),1);

% Fourier transform of noisy image (two lines)
F = fft2(img_noisy);
F = fftshift(F);

% Build Gaussian notch reject filter to remove the two sinusoids
[u,v] = meshgrid(-floor(N/2):ceil(N/2)-1, -floor(M/2):ceil(M/2)-1);
sigma_notch = 3;
D1 = (u - fx).^2 + (v - 0).^2;
D2 = (u + fx).^2 + (v - 0).^2;
D3 = (u - 0).^2 + (v - fy).^2;
D4 = (u - 0).^2 + (v + fy).^2;

H1 = 1 - exp(-(D1)/(2*sigma_notch^2));
H2 = 1 - exp(-(D2)/(2*sigma_notch^2));
H3 = 1 - exp(-(D3)/(2*sigma_notch^2));
H4 = 1 - exp(-(D4)/(2*sigma_notch^2));
H = H1 .* H2 .* H3 .* H4;

% Apply filter in frequency domain
F_filt = F .* H;

% Inverse transform (step by step)
F_ishift = ifftshift(F_filt);
img_ifft = ifft2(F_ishift);
img_filtered = real(img_ifft);
img_filtered = min(max(img_filtered,0),1);

% Show original noisy image
figure
imshow(img_noisy, [])
title('Noisy X-ray Image (periodic vertical and horizontal)')

% Show Fourier Transform of noisy image (separate lines)
log_F_noisy = log(1 + abs(F));
figure
imshow(log_F_noisy, [])
title('Fourier Transform of Noisy Image')

% Show filtered Fourier Transform (separate lines)
log_F_filt = log(1 + abs(F_filt));
figure
imshow(log_F_filt, [])
title('Filtered Fourier Transform (Gaussian notch reject)')

% Show filtered image
figure
imshow(img_filtered, [])
title('Filtered X-ray Image')