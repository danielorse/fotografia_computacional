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
    im2 = zeros(2*f, 2*c, ch);
    im2(1:2:end, 1:2:end, :) = im;

    H = [0 1 0;
         1 4 1;
         0 1 0] / 4;

    for k = 1:ch
        im2(:,:,k) = imfilter(im2(:,:,k), H, 'replicate');
    end
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

%3. Pirámide Laplaciana y aplicaciones

fprintf("\n\n\nParte 3\n\n\n")
function p = lap(im, N)

    im = im2double(im);

    p = cell(1, N);

    for k = 1:(N-1)
        im_red = reduce(im);

        im_amp = amplia(im_red);
        im_amp = im_amp(1:size(im,1), 1:size(im,2), :);

        p{k} = im - im_amp;

        im = im_red;
    end

    p{N} = im;

end
function im = inv_lap(p)

    N = length(p);
    im = p{N};

    for k = (N-1):-1:1

        im = amplia(im);

        % Ajustar tamaño
        f = min(size(im,1), size(p{k},1));
        c = min(size(im,2), size(p{k},2));

        im = im(1:f, 1:c, :);

        im = im + p{k};
    end

end


im = imread('FC_PROY4\img.jpg');

p = lap(im, 4);
addpath('FC_PROY4')
ver_lap(p);


im_rec = inv_lap(p);
imd = im2double(im);
% Diferencia
dif = imd - im_rec;

disp('Max diferencia:');
disp(max(abs(dif(:))));

disp('Min diferencia:');
disp(min(abs(dif(:))));

%Reconstrucción sin nivel p{2}

p2 = p;
p2{2} = zeros(size(p{2}));

im_rec2 = inv_lap(p2);

figure;
imshow(im_rec2);
title('Reconstrucción sin nivel p{2}');

%Fusion imagenes

im = im2double(imread('face_img.jpg'));

ry=(-111:112); rx=(-191:192); 
Yorg=466; 
Xorg=692; 
z1=im(Yorg+ry,Xorg+rx,:);

ydest = 175;
xdest = 425;

res1 = im;

res1(ydest+ry,xdest+rx,:)=z1;

figure;
imshow(res1);
title('Transplante directo');

z0 = im(ydest+ry-1,xdest+rx-1, :);
m = crea_mask(size(z0), [90 180]);

z_simple = m .* z1 + (1 - m) .* z0;
re2 = im;

re2(ydest+ry-1,xdest+rx-1, :) = z_simple;

figure;
imshow(re2);
title('Fusion simple con mascara binaria');

N = 5;

p0 = lap(z0, N);
p1 = lap(z1, N);

pm = cell(1,N);
pm{1} = m;

for k = 2:N
    g = fspecial('gaussian', [7 7], 2.5);

    temp = imfilter(pm{k-1}, g, 'replicate');
    temp = temp(1:2:end, 1:2:end, :);

    pm{k} = temp;
end

g = fspecial('gaussian', [7 7], 2.5);

figure;
imagesc(g); 
colorbar;
title('Filtro gaussiano 7x7 sigma=2.5');

mix = cell(1,N);

for k = 1:N
    mix{k} = pm{k} .* p1{k} + (1 - pm{k}) .* p0{k};
end

z_mix = inv_lap(mix);

res3 = im;
res3(ydest+ry-1,xdest+rx-1, :) = z_mix;

figure;
imshow(res3);
title('Fusion con Piramides');


%3.3 Alineacion

im = im2double(imread('multiplex.jpg'));

h = size(im,1)/3;
w = size(im,2);

B = im(1:h, :, :);
G = im(h+1:2*h, :, :);
R = im(2*h+1:3*h, :, :);


Cx = 1792/2;
Cy = 1600/2;

rx = (-800:800);
ry = (-650:650);

b = B(Cy+ry, Cx+rx);
g = G(Cy+ry, Cx+rx);
r = R(Cy+ry, Cx+rx);

im_color = cat(3, r, g, b);

figure;
imshow(im_color);
title('Imagen combinada sin alinear');


function [dx, dy] = registrar(im, ref)

    N = 5;
    r = 15;
    pyr_im  = cell(1,N);
    pyr_ref = cell(1,N);

    pyr_im{1}  = im;
    pyr_ref{1} = ref;

    for k = 2:N
        pyr_im{k}  = imresize(pyr_im{k-1}, 0.5);
        pyr_ref{k} = imresize(pyr_ref{k-1}, 0.5);
    end

    dx = 0;
    dy = 0;

    for k = N:-1:1

        im_k  = pyr_im{k};
        ref_k = pyr_ref{k};

        dx = round(2*dx);
        dy = round(2*dy);

        best = -inf;
        best_dx = 0;
        best_dy = 0;

        for i = -r:r
            for j = -r:r

                im_shift = circshift(im_k, [dy+i, dx+j]);
                val = sum(sum(im_shift .* ref_k));

                if val > best
                    best = val;
                    best_dx = dx + j;
                    best_dy = dy + i;
                end
            end
        end

        dx = best_dx;
        dy = best_dy;

        disp(['Nivel ' num2str(k) ' -> dx=' num2str(dx) ' dy=' num2str(dy)]);
    end
end
clear;clc;close all;
im = im2double(imread('multiplex3.jpg'));

h = size(im,1)/3;

B = im(1:h,:);
G = im(h+1:2*h,:);
R = im(2*h+1:3*h,:);

Cx = 1792/2;
Cy = 1600/2;

rx = (-800:800);
ry = (-650:650);

b = B(Cy+ry, Cx+rx);
g = G(Cy+ry, Cx+rx);
r = R(Cy+ry, Cx+rx);

[dxg, dyg] = registrar(g, b);
[dxr, dyr] = registrar(r, b);

disp('Final:');
disp([dxg dyg dxr dyr]);

g_al = circshift(g, [dyg dxg]);
r_al = circshift(r, [dyr dxr]);

im_color = cat(3, r_al, g_al, b);

figure;
imshow(im_color);
title('Imagen alineada');

figure;
imshow(im_color(370:620,50:270,:));
title('Zoom cara izquierda');

disp(['G: dx=' num2str(dxg) ' dy=' num2str(dyg)]);
disp(['R: dx=' num2str(dxr) ' dy=' num2str(dyr)]);