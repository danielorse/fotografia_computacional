% ============================

% LABORATORIO 1 - FOTOGRAFÍA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================

% ===== INTRODUCCIÓN =========
% Cargamos la imagen imagen.png
im = imread('FC_PROY1/imagen.png');
% Convertimos a valores entre 0 y 1 (im2double)
im = im2double(im);
% Mostramos la imagen
imshow(im);
% Ponemos a 1 los valores >= 0.5
im(im >= 0.5) = 1;
% Ponemos a 0 los valores < 0.5
im(im < 0.5) = 0;
% Imagen obtenida tras aplicar el indexado lógico
figure
imshow(im);
title('imagen.png tras cambiar el valor de los pixeles');
% Calculamos el error cometido con std2()
desviacion_standard = std2(im2double(imread('FC_PROY1/imagen.png'))- im);


% ===== DITHERING POR DIFUSION DE ERROR =====
function im = dither(im)
    % Convertimos a valores entre 0 y 1 (im2double)
    im = im2double(im);
    % inicializamos error 
    e=0;
    % Recorremos la imagen pixel a pixel
    [filas, columnas] = size(im);
    for fila = 1:filas
        % si la fila es impar, recorremos de izquierda a derecha
        if (mod(fila,2)) == 1
            for columna = 1:columnas
                % Obtenemos el valor del pixel actual sumando el error
                V = im(fila, columna) + e;
                % Comparamos V con 0.5 
                if V >= 0.5
                    im(fila, columna) = 1;
                else
                    im(fila, columna) = 0;
                end
                % Recalculamos el error cometido para poder usarlo con el siguiente pixel
                e = V - im(fila, columna);
            end
        else
        % si la fila es par, recorremos de derecha a izquiera
            for columna = columnas:-1:1
                % Obtenemos el valor del pixel actual sumando el error
                V = im(fila, columna) + e;
                % Comparamos V con 0.5 
                if V >= 0.5
                    im(fila, columna) = 1;
                else
                    im(fila, columna) = 0;
                end
                % Recalculamos el error cometido para poder usarlo con el siguiente pixel
                e = V - im(fila, columna);
            end
        end
    end
end % end de la funión

% Mostramos la imagen obtenida
im = imread('FC_PROY1/imagen.png');
resultado = dither(im);
figure
imshow(resultado);
title('Imagen tras aplicar el dither por difusión de error');

% motramos la zona del ojo
figure
zona_ojo = resultado(110:220, 320:440);
imshow(zona_ojo);
title('Zona del ojo');

% Volvemos a calcular la desviación estandar de la diferencia entre la original y el resultado que hemos obtenido tras aplicar el dithering
desviacion_standard_1 = std2(im2double(imread('FC_PROY1/imagen.png'))- resultado)

% Mostramos la curva de Hilbert que recorre todos los pixeles 512 x 512
load('FC_PROY1/hilbert.mat');
figure
plot(I,J,'g-');
title('Curva de hilbert');

% Nueva función utilizando la curva de Hilbert
function im = dither_hilbert(im)
    % Cargamos curva de Hilbert 
    load('FC_PROY1/hilbert.mat');
    % Convertimos a valores entre 0 y 1
    im = im2double(im);
    % Inicializamos e error
    e = 0;
    % Recorremos la imagen 
    for k = 1:length(I)
        % Obtenemos coordenadas
        fila = I(k);
        columna = J(k);
        % Obtener el valor del píxel actual sumando el error
        V = im(fila, columna) + e;
        % Comparar V 
        if V >= 0.5
            im(fila, columna) = 1;
        else
            im(fila, columna) = 0;
        end
        % Recalcular el error cometido para usarlo en el siguiente píxel
        e = V - im(fila, columna);
    end
end

% Mostramos la imagen obtenida
im = imread('FC_PROY1\imagen.png');
result_hilbert = dither_hilbert(im);
figure
imshow(result_hilbert);
title('Resultado de aplicar dithering con la curva de hilbert');
% motramos la zona del ojo
figure
zona_ojoH = result_hilbert(110:220, 320:440);
imshow(zona_ojoH);
title('Zona del ojo - hilbert');






