% ============================

% LABORATORIO 1 - FOTOGRAFÍA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================

%filtrado
G = fspecial('gauss',7,1.5);

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
desviacion_standard = std2(im2double(imread('FC_PROY1/imagen.png'))- im)
% Calculamos la desviación fiiltrada
im_filtrada = imfilter(im, G, 'symm');
desviacion_standard_filtrada = std2(im_filtrada - im2double(imread('FC_PROY1/imagen.png')))


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
desviacion_standard_dither = std2(im2double(imread('FC_PROY1/imagen.png'))- resultado)

% desviaciónen estandar filtrada
im_filtrada_dither = imfilter(resultado, G, 'symm');
desviacion_filtrada_dither = std2(im_filtrada_dither - im2double(imread('FC_PROY1/imagen.png')))

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

desviacion_hilbert = std2(im2double(imread('FC_PROY1/imagen.png'))- result_hilbert)
% desviación hilbert filtrada
im_filtrada_hilbert = imfilter(result_hilbert, G, 'symm');
desviacion_filtrada_hilbert = std2(im_filtrada_hilbert - im2double(imread('FC_PROY1/imagen.png')))

% funcion para repatir el error a sus 3 vecinos
function im = dither_3vecinos(im)
    % Convertimos a valores entre 0 y 1 (im2double)
    im = im2double(im);
    
    % Recorremos la imagen pixel a pixel
    [filas, columnas] = size(im);
    
    for fila = 1:filas
        % si la fila es impar recorremos de izquierda a derecha
        if (mod(fila,2)) == 1
            for columna = 1:columnas
                % Obtenemos el valor del pixel actual
                V = im(fila, columna);
                
                % Comparamos V con 0.5
                if V >= 0.5
                    im(fila, columna) = 1;
                else
                    im(fila, columna) = 0;
                end
                
                % Calculamos el error cometido para usarlo con el siguiente  
                e = V - im(fila, columna);
                
                % Difundimos el error a 3 vecinos
                % Derecha (4/8)
                if columna+1 <= columnas
                    im(fila, columna+1) = im(fila, columna+1) + e*(4/8);
                end
                % Abajo (3/8)
                if fila+1 <= filas 
                    im(fila+1, columna) = im(fila+1, columna) + e*(3/8);
                end
                % Abajo-derecha (1/8)
                if (fila+1 <= filas) && (columna+1 <= columnas)
                    im(fila+1, columna+1) = im(fila+1, columna+1) + e*(1/8);
                end
            end
        else
            % si la fila es par, recorremos de derecha a izquierda
            for columna = columnas:-1:1
                % Obtenemos el valor del pixel actual
                V = im(fila, columna);
                
                % Comparamos V con 0.5
                if V >= 0.5
                    im(fila, columna) = 1;
                else
                    im(fila, columna) = 0;
                end
                
                % Calculamos el error cometido
                e = V - im(fila, columna);
                
                % Difundimos el error a 3 vecinos
                % Izquierda (4/8)
                if columna-1 >= 1
                    im(fila, columna-1) = im(fila, columna-1) + e*(4/8);
                end
                % Abajo (3/8)
                if fila+1 <= filas
                    im(fila+1, columna) = im(fila+1, columna) + e*(3/8);
                end
                % Abajo-izquierda (1/8)
                if (fila+1 <= filas) && (columna-1 >= 1)
                    im(fila+1, columna-1) = im(fila+1, columna-1) + e*(1/8);
                end
            end
        end
    end
end % end de la funion

% Mostramos la imagen obtenida tras aplicar el error a 3 vecinos
im = imread('FC_PROY1\imagen.png');
result3vecinos = dither_3vecinos(im);
figure
imshow(result3vecinos);
title('Resultado de aplicar error a los 3 vecinos');

% motramos la zona del ojo
figure
zona_ojo3V = result3vecinos(110:220, 320:440);
imshow(zona_ojo3V);
title('Zona del ojo - 3 vecinos');

% calculamos la desviación al haber aplicado aproximación a los 3 vecinos   
desviacion_3vecinos = std2(im2double(imread('FC_PROY1/imagen.png'))- result3vecinos)
% desviación 3 vecinos filtrada
im_filtrada_3vecinos = imfilter(result3vecinos, G, 'symm');
desviacion_filtrada_3vecinos = std2(im_filtrada_3vecinos - im2double(imread('FC_PROY1/imagen.png')))










