% ============================

% LABORATORIO 1 - FOTOGRAFÍA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================


% ===== Ordered dithering =====

im = imread('FC_PROY1/imagen.png');
im = im2double(im);
im2 = im;


%Creamos la imagen random
imrandom = rand(size(im));
%Hacemos la comparativa de la imagen igual que en el apartado 1
im(im>=imrandom) = 1;
im(im<imrandom) = 0;
figure
imshow(im2);
title("Imagen.png")
figure
imshow(im);
title("Imagen.rng")
std2(im2-im)
