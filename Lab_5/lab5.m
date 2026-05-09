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
% im_cartel = double(imread('billboard.jpg')) / 255;
% [N, M, ~] = size(im_cartel);

% Medimos las esquinas del cartel
% figure; imshow(im_cartel);
% title('Haz clic en las 4 esquinas que queramos: Superior-Izq, Superior-Der, Inferior-Der, Inferior-Izq');
% hold on;

% u_cartel = zeros(1,4);
% v_cartel = zeros(1,4);
% for k = 1:4
%     [u_cartel(k), v_cartel(k)] = ginput(1);
%     plot(u_cartel(k), v_cartel(k), 'g.', 'MarkerSize', 20);
% end
% hold off;

% Ajustamos las coordenadas
% x_cartel = [1      M   M   1     ];
% y_cartel = [1      1     N   N  ];
% Calculamos P
% P = get_proy(x_cartel, y_cartel, u_cartel, v_cartel);
% fprintf('Matriz P del cartel:\n');
% show_mat(P);

% iP = inv(P);
% im_deformada = warp_img(im_cartel, iP);
% figure; imshow(im_deformada); title('Transformación dentro del espacio del cartel');


% == Fusión de las imágenes ==
% Calcula la mascara de la imagen
% mascara = ~isnan(im_deformada);
% Borramos la zona del cartel en la imagen original
% im_fusion = im_cartel;
% im_fusion(mascara) = 0;
% Pegamos la imagen deformada en la zona del cartel
% im_fusion(mascara) = im_deformada(mascara);
% figure; imshow(im_fusion); title('Imagen fusionada');

% Repetimos el proceso sin volver a medir la zona del cartel
% im_bucle = im_fusion;
% for copias = 1:3 % Numero de veces que queremos repetir el proceso
%     im_deformada_k = warp_img(im_bucle, iP);
%     mascara_k = ~isnan(im_deformada_k(:,:,1));
%     for c = 1:size(im_bucle, 3)
%         canal = im_bucle(:,:,c);
%         canal_d = im_deformada_k(:,:,c);
%         canal(mascara_k) = canal_d(mascara_k);
%         im_bucle(:,:,c) = canal;
%     end
% end
% figure; imshow(im_bucle); title('Imagen recursiva');


% ==== 2. Morphing ==== 
fprintf('=== MORPHING ===\n');
% TIANGULACIÓN Y CÁLCULO DE MATRICES DE TRANSFORMACIÓN
fprintf('Triangulación y cálculo de matrices de transformación...\n');

% Cargamos las  imágenes y ponemos en formato
im1 = double(imread('willis.jpg')) / 255;
im2 = double(imread('ant.jpg'))    / 255;
% Cargamos los vectores
load puntos_morph   
% Visualizamos im1 con sus puntos de control
figure;
imshow(im1); hold on;
plot(x1, y1, 'r.', 'MarkerSize', 12);
title('willis.jpg con puntos de control');
hold off;

% Calculamos los puntos medios
u = 0.5 * (x1 + x2);
v = 0.5 * (y1 + y2);
% Triangulación de Delaunay sobre los puntos medios
T = delaunay(u, v);
NT = size(T, 1);
fprintf('Número de triángulos NT = %d\n', NT);
% Visualizamos im2 con sus puntos de control y con la triangulación
figure;
imshow(im2); hold on;
triplot(T, x2, y2, 'm');          % triangulación
plot(x2, y2, 'r.', 'MarkerSize', 12);
title('ant.jpg con puntos de control y triangulación');
hold off;

% Arrays de celdas para las NT matrices inversas
iP1 = cell(1, NT);
iP2 = cell(1, NT);

for k = 1:NT
    % 1) Índices de los vértices del triángulo k
    idx = T(k, :);
    % 2) Coordenadas de origen en im1 e im2, osea los vertices del triangulo
    X1 = x1(idx);   Y1 = y1(idx);   % vértices en imagen 1 (willis)
    X2 = x2(idx);   Y2 = y2(idx);   % vértices en imagen 2 (ant)
    % destino 
    U = u(idx);     V = v(idx);

    iP1{k} = get_afin(U, V, X1, Y1);
    iP2{k} = get_afin(U, V, X2, Y2);
end

% mosttramos las matrices del triángulo nº 3
fprintf('\niP1 triángulo 3:\n'); show_mat(iP1{3});
fprintf('\niP2 triángulo 3:\n'); show_mat(iP2{3});


% RUTINA DE DEFORMAR UNA IMAGEN
%fprintf('Escribimos una rutina para deformar una imagen\n');
% Comprobamos los valorees para poder elegir la mejor transformacion

[N, M, ~] = size(im1);
zona = determina_triang(T, u, v, N, M);
% Deformamos las imagenes
im1_def = warp_img_trozos(im1, iP1, zona);
im2_def = warp_img_trozos(im2, iP2, zona);
% Mostramos las imagenes
figure; imshow(im1_def); title('willis deformada');
figure; imshow(im2_def); title('ant deformada');
% Hacemos la mezcla con la media
im_mezcla = 0.5 * im1_def + 0.5 * im2_def;
figure; imshow(im_mezcla); title('Imagen de la mezcla');


% Cambiamos el valor de t a 0.7
t = 0.7;
% Recalculamos los puntos destino (u,v)
u_t = (1-t) * x1 + t * x2;
v_t = (1-t) * y1 + t * y2;

% Recalculamos las matrices iP1 e iP2 con los nuevos puntos
iP1_t = cell(1, NT);
iP2_t = cell(1, NT);
for k = 1:NT
    idx = T(k, :);
    X1 = x1(idx);  Y1 = y1(idx);
    X2 = x2(idx);  Y2 = y2(idx);
    U  = u_t(idx); V  = v_t(idx);
    iP1_t{k} = get_afin(U, V, X1, Y1);
    iP2_t{k} = get_afin(U, V, X2, Y2);
end
% Recalculamos zona con los nuevos (u_t, v_t)
zona_t = determina_triang(T, u_t, v_t, N, M);
% Deformamos las imagenes
im1_d = warp_img_trozos(im1, iP1_t, zona_t);
im2_d = warp_img_trozos(im2, iP2_t, zona_t);
figure; imshow(im1_d); title('willis deformada (t=0.7)');
figure; imshow(im2_d); title('ant deformada (t=0.7)');
% Mezcla ponderada final
res = (1-t) * im1_d + t * im2_d;
figure; imshow(res); title('Mezcla final morphing t=0.7');


% OPTIMIZACIÓN DE LA RUTINA DE WARP_IMG_TROZOS()
N_rep = 100;
% Versión NO optimizada
tic
for i = 1:N_rep
    warp_img_trozos(im1, iP1, zona);
end
t_lenta = toc;
fprintf('\nVersión no optimizada (100x): %.3f s  →  %.4f s/iter\n', t_lenta, t_lenta/N_rep);
% Versión optimizada
tic
for i = 1:N_rep
    warp_img_trozos_optimizada(im1, iP1, zona);
end
t_rapida = toc;
fprintf('Versión optimizada    (100x): %.3f s  →  %.4f s/iter\n', t_rapida, t_rapida/N_rep);
fprintf('Aceleración: x%.1f\n', t_lenta/t_rapida);