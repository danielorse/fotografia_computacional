% ============================

% LABORATORIO 1 apartado 4 - FOTOGRAFÍA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================

% ===== Mostrar imagen oculta al igual que con cervino.png del lab0=========
clear; clc; close all;

im = imread('FC_PROY1/imagen.png');
% Extraemos el bit menos significativo
V =1;
im_oculta = bitand(im, V);
% Mostramos la imagen oculta igual que con el lab 0
figure;
imshow(im_oculta*255);  
title('Imagen oculta');
% con esto podemos observar la imagen oculta en escala de grises que se repite 3 veces (1 por canal de color)

% Medidas de la imagen oculta
filas = 340;
columnas = 256;
separacion = 512;
nbits = filas*columnas; % nbits por canal (según el enunciado es a coloir asiq 3 canales)
% extramos los bits de cada canal
    % - Canal Rojo -
    bits_rojo_p1 = im_oculta(1:170, 1:256);
    bits_rojo_p2 = im_oculta(1:170, 257:512);
    Rojo = [bits_rojo_p1; bits_rojo_p2]; 
    % - Canal Verde -
    bits_verde_p1 = im_oculta(172:341, 1:256);
    bits_verde_p2 = im_oculta(172:341, 257:512);   
    Verde = [bits_verde_p1; bits_verde_p2];
    % - Canal Azul -
    bits_azul_p1 = im_oculta(343:512, 1:256);
    bits_azul_p2 = im_oculta(343:512, 257:512);
    Azul = [bits_azul_p1; bits_azul_p2];
% combinamos los canales para obtener la imagen oculta a color
imagen_oculta_color = cat(3, Rojo, Verde, Azul);
% Mostramos la imagen oculta a color
figure;
imshow(imagen_oculta_color*255);
title('Imagen oculta a color');

