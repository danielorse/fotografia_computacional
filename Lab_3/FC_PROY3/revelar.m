% ============================

% LABORATORIO 3 - FOTOGRAFÍA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================

clear; clc; close all

% 1.1) Manejo de imágenes RAW
im = imread('black.pgm');  % "black frame"

    % Extraemos los 4 cojnuntos de cada canal y los guardamos en matrices
    R  = im(1:2:end, 1:2:end);
    G1 = im(1:2:end, 2:2:end);
    G2 = im(2:2:end, 1:2:end);
    B  = im(2:2:end, 2:2:end);
    % Histograma de R y gráfico rango [-5 25] en eje X
    figure;
    histogram(double(R(:)), 100); xlim([-5 25]);
    grid on; % cuadrícula 
    title('Histograma del canal R'); xlabel('Valor del pixel'); ylabel('Num pixeles');
    % RAngo del canal rojo
    fprintf('El rango de R es: [%d, %d]\n', min(R(:)), max(R(:)));

    % Calculo del nivel de ruido
    mu = 0;
    s = 0.5;
    r = mu + s*randn(1000);
    % Comprobamos la estimación
    fprintf('media = %.2f, sigma = %.2f\n', mean2(r), std2(r));
    fprintf('\n');
    
    % Cambiamos valores del ruido por su entero más próximo
    I = round(r);
    fprintf('Tras cuantificar:\n');
    fprintf('media = %.2f, sigma = %.2f\n', mean2(I), std2(I));
    fprintf('\n');

    % Estimamos p0 yy valor de la desviación
    po = sum (I (:)== 0)

% 3.1)  Lectura y escalado de los datos RAW

raw=imread('raw.pgm');  


% 3.1) Obtencion y procesado imagen BW


% 3.2) Demultiplexado, paso a sRGB + gamma


% 3.3) Equilibrado de blancos

% 3.4) Algoritmo alternativo WB


% 3.5) Almacenamiento

