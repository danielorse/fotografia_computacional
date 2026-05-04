% ============================

% LABORATORIO 5 - FOTOGRAFÍA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================
clear;clc;close all;
addpath('FC_PROY5')

%Obtención de la matriz P de una transformación proyectiva 

x = [0 600 465];
y = [0 65 680];
u = [275 655 365];
v = [30 285 755];

P = get_afin(x,y,u,v);

[u2,v2] = convertir(x,y,P);

P_inv = inv(P);

[x2,y2] = convertir(u,v,P_inv);

show_mat(P_inv);

x = [275 655 365 25];
y = [30 285 755 340];
u = [0 600 465 215];
v = [0 65 680 585];


P = get_proy(x,y,u,v);

show_mat(P);

[u2,v2] = convertir(x,y,P);
du = u2 - u;
dv = v2 - v;

fprintf('Diferencias (du,dv):\n');
disp([du' dv'])

[up,vp] = convertir(200,100,P);
fprintf('Punto (200,100) transformado:\n');
disp([up vp])

fprintf("P2 = get_proy(u,v,x,y)\n")
P2 = get_proy(u,v,x,y);
show_mat(P2);
fprintf("Inv de P\n")
iP = inv(P);
show_mat(iP);

disp("Proporcion P2 y inv P")
disp(P2./iP);

%Deformación de una imagen usando transformaciones lineales
im = double(imread('foto.jpg')) / 255;
im2 = warp_img(im, iP);
figure; imshow(im2); title('Imagen deformada');

%imselfie = imread('SelfiePersonal1.jpg');
%demoP4(imselfie);

%FUNCIONES
function [u,v] = convertir(x,y,P)
x = x(:)';
y = y(:)';

X = [x; y; ones(1,length(x))];

U = P * X;

u = U(1,:) ./ U(3,:);
v = U(2,:) ./ U(3,:);
end


function P=get_proy(x,y,u,v)

x=x'; y=y'; u=u'; v=v';
z=0*x; unos=x.^0; % 0's y 1's

M = [x y unos z z z -u.*x -u.*y; 
     z z z x y unos -v.*x -v.*y];

uv=[u;v]; 
sol= M\uv;

P = [sol(1:3)'; 
     sol(4:6)'; 
     sol(7:8)' 1];

end

%Deformación de una imagen usando transformaciones lineales (DANI)

function im2 = warp_img(im, iP)

% Dimensiones de la imagen
[N, M, C] = size(im);

% Reservamos la imagen de salida y matrices de coordenadas a interpolar
im2 = zeros(N, M, C);
X = zeros(N, M);  
Y = zeros(N, M);  

% Recorremos las coordenadas en la imagen de salida
for u = 1:M
    for v = 1:N
        % Aplicamos transformación inversa
        [x, y] = convertir(u, v, iP);
        X(v, u) = x;
        Y(v, u) = y;
    end
end

% Interpolamos cada plano de color por separado
for c = 1:C
    im2(:,:,c) = interp2(im(:,:,c), X, Y, 'bicubic');
end
end 

% IMÁGENES RECURSIVAS

% == Transformación de la imagen dentro del espacio del cartel ==
% Cargamos billboard jpg
im_cartel = double(imread('billboard.jpg')) / 255;
[N, M, ~] = size(im_cartel);

% Medimos las esquinas del cartel
figure; imshow(im_cartel);
title('Haz clic en las 4 esquinas que queramos: Superior-Izq, Superior-Der, Inferior-Der, Inferior-Izq');
hold on;

u_cartel = zeros(1,4);
v_cartel = zeros(1,4);
for k = 1:4
    [u_cartel(k), v_cartel(k)] = ginput(1);
    plot(u_cartel(k), v_cartel(k), 'g.', 'MarkerSize', 20);
end
hold off;

% Ajustamos las coordenadas
x_cartel = [1      M   M   1     ];
y_cartel = [1      1     N   N  ];
% Calculamos P
P = get_proy(x_cartel, y_cartel, u_cartel, v_cartel);
fprintf('Matriz P del cartel:\n');
show_mat(P);

iP = inv(P);
im_en_cartel = warp_img(im_cartel, iP);
figure; imshow(im_en_cartel); title('Transformación dentro del espacio del cartel');

% == Fusión de las imágenes ==
% Usamos una máscara para identificar los píxeles que nos sirven de la imagen deformada
mascara = ~isnan(im_en_cartel(:,:,1));   % matriz lógica NxM

% Para cada canal reemplazamos los píxeles
im_fusion = im;                          % partimos de la imagen original
for c = 1:size(im, 3)
    canal_orig      = im(:,:,c);
    canal_deformado = im_en_cartel(:,:,c);
    canal_orig(mascara) = canal_deformado(mascara);
    im_fusion(:,:,c) = canal_orig;
end

figure; imshow(im_fusion); title('Imagen fusionada');
