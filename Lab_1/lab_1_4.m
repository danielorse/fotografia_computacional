clc;clear;

im = imread('FC_PROY1/imagen.png');

menos = bitand(im, 1);   

figure
imshow(menos)
title("Imagen y RGB332");