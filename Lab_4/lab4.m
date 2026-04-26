% ============================

% LABORATORIO 4 - FOTOGRAFÍA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================

% 1. Uso de filtros para cambiar el tamaño de una imagen

 % Reducción del tamaño de una imagen
    
    % Mostramos la imagen original
    im = imread('brick.jpg');
    imshow(im);
    title('Imagen original');

    % funcion para reducir a la mitad el tamaño de una imagen (a color)
    function im = reduce(im)
        H = raised_cos(3);
        imf = imfilter(im, H, 'same', 'replicate');
        im2 = imf(1:2:end, 1:2:end, :);
        im = im2;
    end

    % recibe N y devuelve el filtro 2D (NxN)
    function H = raised_cos(N)
        L = (N-1)/2;
        k = -L:L;
        h = 1 + cos(pi*k/(L+1));
        h = h / sum(h);
        H = h' * h;
    end

    % mostramos la imagen submuestreada
    im2 = reduce(im);
    im4 = reduce(im2);
    figure, imshow(im2);
    title('Imagen submuestreada');

    % Filtros para N=3 y N=5
    H3 = raised_cos(3)
    H5 = raised_cos(5)

 % Ampliación de una imagen
    
    % Función que recipe una imagen y la amplía al doble de su tamaño
    function im2 = amplia(im)
    [N,M,C] = size(im);
    im2 = zeros(2*N, 2*M, C, class(im));
    im2(1:2:end, 1:2:end, :) = im;
    end

    imagen = imread('brick.jpg');
    im3 = amplia(imagen);
    figure, imshow(im3);
    title('Imagen ampliada');

    