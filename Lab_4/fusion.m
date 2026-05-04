clear;clc;


cara = im2double(imread('cara.jpg'));   % Ojos
mano = im2double(imread('mano.jpg'));   % Final
% figure
% imshow(cara)
% 
% figure
% imshow(mano)

ry = (-111:112); 
rx = (-191:192); 

% OJO 1

Yorg1 = 960; 
Xorg1 = 848; 

z1_1 = cara(Yorg1+ry, Xorg1+rx, :);

ydest1 = 939;
xdest1 = 860;

z0_1 = mano(ydest1+ry-1, xdest1+rx-1, :);


% OJO 2


Yorg2 = 980;  
Xorg2 = 1372; 

z1_2 = cara(Yorg2+ry, Xorg2+rx, :);


ydest2 = 960; 
xdest2 = 1401;  

z0_2 = mano(ydest2+ry-1, xdest2+rx-1, :);


m = crea_mask(size(z0_1), [90 180]);



fusion = @(z0,z1,m) fusion_laplaciana(z0,z1,m);



z_mix1 = fusion(z0_1, z1_1, m);
z_mix2 = fusion(z0_2, z1_2, m);


res = mano;

res(ydest1+ry-1, xdest1+rx-1, :) = z_mix1;
res(ydest2+ry-1, xdest2+rx-1, :) = z_mix2;



figure;
imshow(res);
title('Fusion mano ojos');


% FUNCIONES


function z_mix = fusion_laplaciana(z0, z1, m)

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

    mix = cell(1,N);

    for k = 1:N
        mix{k} = pm{k} .* p1{k} + (1 - pm{k}) .* p0{k};
    end

    z_mix = inv_lap(mix);

end

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
    function H = raised_cos(N)
        L = (N-1)/2;
        k = -L:L;
        h = 1 + cos(pi*k/(L+1));
        h = h / sum(h);
        H = h' * h;
    end

    function im2 = reduce(im)
        H = raised_cos(3);
        imf = imfilter(im, H, 'same', 'replicate');
        im2 = imf(1:2:end, 1:2:end, :);
    end

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

