% ============================

% LABORATORIO 4 - FOTOGRAFÍA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================

clear;clc;
% 1. Uso de filtros para cambiar el tamaño de una imagen

 % Reducción del tamaño de una imagen

    % recibe N y devuelve el filtro 2D (NxN)
    function H = raised_cos(N)
        L = (N-1)/2;
        k = -L:L;
        h = 1 + cos(pi*k/(L+1));
        h = h / sum(h);
        H = h' * h;
    end

    % funcion para reducir a la mitad el tamaño de una imagen (a color)
    function im2 = reduce(im)
        H = raised_cos(3);
        imf = imfilter(im, H, 'same', 'replicate');
        im2 = imf(1:2:end, 1:2:end, :);
    end
    
    % H3 = raised_cos(3)
    % H5 = raised_cos(5)
    % mostramos la imagen submuestreada
    im = imread('FC_PROY4\brick.jpg');
    imr = reduce(im);
    imr2 = reduce(imr);
    figure;
    subplot(1,3,1); imshow(im); title('Original');
    subplot(1,3,2); imshow(imr); title('Reducida x2');
    subplot(1,3,3); imshow(imr2); title('Reducida x4');


    % Ampliación del tamaño de una imagen

    function im2 = amplia(im)

    im = im2double(im);

    [f, c, ch] = size(im);

    % Paso 1: insertar ceros
    im2 = zeros(2*f, 2*c, ch);
    im2(1:2:end, 1:2:end, :) = im;

    % Añadir marco (replicar penúltima fila/columna)
    im2(end,:,:) = im2(end-1,:,:);
    im2(:,end,:) = im2(:,end-1,:);

    % Filtro 3x3
    H = [0 1 0;
         1 4 1;
         0 1 0] / 4;

    % Filtrado
    for k = 1:ch
        im2(:,:,k) = imfilter(im2(:,:,k), H, 'replicate');
    end

    % Eliminar marco
    im2 = im2(1:end-1, 1:end-1, :);
end
%     H = [0 1 0;
%      1 4 1;
%      0 1 0] / 4;
% 
% disp('Mascara 3x3:');
% disp(H);
% 
% disp('Suma de coeficientes:');
% disp(sum(H(:)));
% 
im_amp = amplia(im);

figure;
imshow(im_amp);
title('Zoom esquina inferior derecha');

H_bayer = [0 1 0;
           1 4 1;
           0 1 0] / 4;

disp('Mascara Bayer:');
disp(H_bayer);

disp('Suma coeficientes:');
disp(sum(H_bayer(:)));

% REALCE DE BORDES

im = im2double(imread('FC_PROY4\img.jpg'));

% Imagen suavizada
H = raised_cos(5);
Is = imfilter(im, H, 'replicate');

detalle = im - Is;

% Min y max del detalle
disp('Min detalle:');
disp(min(detalle(:)));
disp('Max detalle:');
disp(max(detalle(:)));

% Visualizar detalle (centrado en gris)
figure;
imshow(detalle + 0.5);
title('Detalle visualizado');


alpha = 1.8;
im_rec = Is + alpha * detalle;

% Clamp a [0,1]
im_rec(im_rec < 0) = 0;
im_rec(im_rec > 1) = 1;

% Min y max imagen final
disp('Min imagen final:');
disp(min(im_rec(:)));
disp('Max imagen final:');
disp(max(im_rec(:)));

[f, c, ch] = size(im);

im_comp = im;
im_comp(f/2+1:end,:,:) = im_rec(f/2+1:end,:,:);
im_comp(f/2,:,:) = 0;

figure;
imshow(im_comp);
title('Comparacion original (arriba) vs realzada (abajo)');


% REGISTRO DE IMÁGENES
fprintf('\n\n\nParte 2\n\n\n')
im1 = im2double(imread('FC_PROY4\test1.jpg'));
im2 = im2double(imread('FC_PROY4\test2.jpg'));


% Obtener detalle
H = raised_cos(5);

Is1 = imfilter(im1, H, 'replicate');
Is2 = imfilter(im2, H, 'replicate');

d1 = im1 - Is1;
d2 = im2 - Is2;

%Extraer trozos centrales
R = 15;

T1 = d1(100-R:100+R, 100-R:100+R);
T2 = d2(100-R:100+R, 100-R:100+R);
C = imfilter(d1, T2, 'replicate');
figure;
imagesc(C); colorbar;
title('Correlacion R=15');

% Maximo
[M,pos] = max(C(:));
[i,j] = ind2sub(size(C),pos);

dx = j - (100 + R);
dy = i - (100 + R);

disp('R=15');
disp([dx dy]);