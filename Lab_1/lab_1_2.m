% ============================

% LABORATORIO 1 - FOTOGRAFÍA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================


% ===== Ordered dithering =====
clear;clc;
im = imread('FC_PROY1/imagen.png');
im = im2double(im);
im2 = im;


%Creamos la imagen random
imrandom = rand(size(im));
%Hacemos la comparativa de la imagen igual que en el apartado 1 luego al
%final del punto 2 nos damos cuenta que es bastante erroneo y lo mejoramos
im(im>=imrandom) = 1;
im(im<imrandom) = 0;
figure
imshow(im2);
title("Imagen.png");
figure
imshow(im);
title("Imagen.rng");
std2(im2-im);
%Algoritmo de dithering ordenado 

function R = dord(n)
    M = 0;
    Y = 1;
    for i = 1:n
        Y=Y/4;
        M = [M, M+2*Y,
            M+3*Y, M+Y];
    end
    R = (M + Y/2);
end
im3 = im2;
A = repmat(dord(3),size(im3)/8);
im3(im3>=A) = 1;
im3(im3<A) = 0;
figure
imshow(im3);
title("Dithering Ordenado");
figure
zona_ojo = im3(110:220, 320:440);
imshow(zona_ojo);
title('Zona del ojo');

std2(im2-im3);

im4 = im2;
M = repmat(dord(2),size(im4)/4);
im4(im4>=M) = 1;
im4(im4<M) = 0;
figure
zonagrises = im4(1:60, :);
imshow(zonagrises);
title("EscalaGrises 4x4");

%Ruido azul
load('FC_PROY1/blue.mat');
B1 = repmat(B, 2 ,2);
R1 = rand([128,128]);
figure
imshow([R1 B1])
title("Ruido blanco y azul")


G = fspecial('gauss',7,1.5);

R2 = imfilter(R1, G, 'symm');
B2 = imfilter(B1, G, 'symm');

figure
imshow([R2 B2])
title("Ruido blanco y azul filtrado")

im6 = im2;
B3 = repmat(B, 512/64 ,512/64);
im6(im6>=B3) = 1;
im6(im6<B3) = 0;
figure
imshow(im6);
title("Ruido azul imagen");


%Ruido azul imagen a color
imc = imread("FC_PROY1/color.jpg");
size(imc);
BC = repmat(B,512/64,512/64);
imc = im2double(imc);
R = imc(:,:,1);
G = imc(:,:,2);
V = imc(:,:,3);


%Aqui nos dimos cuenta de que la comparativa no tenia mucho sentido y la
%mejoramos
R = R >= BC;
G = G >= BC;
V = V >= BC;
imcfinal = double(cat(3, R, G, V));
figure
imshow(imcfinal);
title("Imagen final a color")