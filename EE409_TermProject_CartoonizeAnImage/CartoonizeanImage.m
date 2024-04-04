clc; clear; close all;

img = imread("pala.jpg");
[M, N, I] = size(img);

subplot(131);
imshow(img)
title('Original Image');

% A ---  Histogram Equalization  ------------------------------------------------------------------------------------------------------

img_filtered = img;

% Apply medfilt2 on each color

for c = 1:I
    img_filtered(:, :, c) = medfilt2(img(:, :, c), [5, 5]);
end

image_lab = rgb2lab(img_filtered);

max_luminosity = 100;
L = image_lab(:,:,1)/max_luminosity;

image_histeq = image_lab;
image_histeq(:,:,1) = histeq(L)*max_luminosity;
image_histeq = lab2rgb(image_histeq);


% % B ---  Edge Detection using Sobel   ------------------------------------------------------------------------------------------------------

[M, N, I] = size(img_filtered);
dup = zeros(M,N);

for i = 1:M
    for j = 1:N
        dup(i,j) = img_filtered(i,j);
    end
end

edges = edge(dup, "sobel", "both");

sel = strel("rectangle", [1, 1]);
dilated_img = imdilate(edges, sel);
dilated_img = imcomplement(dilated_img);


% C --- Bilateral Filtering  -----------------------------------------------------------------------------------------------

img1 = image_histeq;

img1 = img1+0.03*randn(size(img1));
img1(img1<0) = 0; img1(img1>1) = 1;

w     = 5;       % bilateral filter half-width
sigma = [3 0.1]; % bilateral filter standard deviations

image_filtered = bfilter2(img1,w,sigma);


% % D --- Color Quantization  -----------------------------------------------------------------------------------------------
% 
quantize_img = img_filtered;

threshold = 6;
threshRGB = multithresh(quantize_img, threshold);
threshForPlanes = zeros(3,7);

for i = 1:3
    threshForPlanes(i, : ) = multithresh(quantize_img(:, :, i), 7);
end

value = [0, threshRGB(2:end), 255];
quantRGB = imquantize(quantize_img, threshRGB, value);

% Apply medfilt2 on each color
C_new = quantRGB;

for c = 1:3
    C_new(:, :, c) = medfilt2(quantRGB(:, :, c), [5, 5]);
end


% % E --- Recombine (Sharpening)   -----------------------------------------------------------------------------------------------
  
cartoon = imsharpen(C_new);

cartoon_edge = imfuse(C_new, dilated_img,"blend");

subplot(132);
imshow(cartoon)
title('Cartoon Image without Edges');

subplot(133);
imshow(cartoon_edge)
title('Cartoon Image with Edges');

