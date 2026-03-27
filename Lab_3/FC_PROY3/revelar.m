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
    p0 = sum (I (:)== 0)/numel(I);
    p0sigma = sqrt(2) / (4 * erfinv(p0));
    fprintf('Calculo de p0 y sigma:\n');
    fprintf('p0 = %.4f, p0sigma = %.4f\n', p0, p0sigma);
    fprintf('\n');
    
    %Nueva estimacion de sigma con I filtrado
    Isin0 = I;
    Isin0(Isin0<0) = 0;
    p00 = sum (Isin0 (:)== 0)/numel(Isin0);
    p00sigma = sqrt(2) / (4 * erfinv(p00));
    fprintf('Calculo de p0 sin negativos y sigma:\n');
    fprintf('p0 = %.4f, p0sigma = %.4f\n', p00, p00sigma);
    fprintf('\n');

    %Contar I>0
    %Como tenemos el numero de negativos y 0's con el truncamiento
    %anterior, podemos restar ese numero al total para trabajar con ello
    nPositivos = sum(Isin0 (:)>0);
    pno0 = (nPositivos * 2)/numel(Isin0);
    p0real = 1- pno0;
    p0realsigma = sqrt(2) / (4 * erfinv(p0real));

    fprintf('Calculo corregido de p0 y sigma:\n');
    fprintf('p0 = %.2f, sigma = %.2f\n', p0real, p0realsigma);
    fprintf('\n');
    
    % Aplicamos la estimación Sigma a los datos de los canals
    canales = {R, G1, G2, B};
    for k = 1:4
        canal = canales{k};
        canalSinNeg = canal; 
        % en caso de haber algun valor negativo lo ponemos a 0 igual que en apartados previos
        canalSinNeg(canalSinNeg < 0) = 0; 
        % A partir de los valores positivos  estimamos el p0 corregido
        nPositivos = sum(canalSinNeg(:) > 0);
        pno0 = (nPositivos * 2) / numel(canalSinNeg);
        p0real = 1 - pno0;
        % calculamos las estimaciones
        sigma_mejorada(k) = sqrt(2) / (4 * erfinv(p0real));
        sigma_std2(k) = std2(double(canal));
    end
    
    % Mostramos resultados
    nombres = {'R', 'G1', 'G2', 'B'};
    fprintf('Estimación mejorada de sigma:\n');
    for k = 1:4
        fprintf('%s = %.2f\n', nombres{k}, sigma_mejorada(k));
    end

    fprintf('\nEstimación de sigma con std2():\n');
    for k = 1:4
        fprintf('%s = %.2f\n', nombres{k}, sigma_std2(k));
    end

    % Cargamos datos del ruido térmico
    load data_term
    % Guardamos el valor sigma estimado en S
    S = zeros(size(T));
    for k = 1:length(T)
        frame = black(:,:,k);
        S(k) = std2(double(frame));
    end
    % Gráfica de los valores obtenidos
    figure;
    plot(log2(T), S, 'o-');
    grid on;
    xlabel('log2(T)'); ylabel('\sigma estimada');
    title('Ruido térmico segun tiempo de exposición');
    % Mostramos también los valores obtenidos
    fprintf('Valores de T:\n');
    fprintf(' %.4f', T);
    fprintf('\n');
    fprintf('Valores de S:\n');
    fprintf(' %.4f', S);
    fprintf('\n');


% 2) Estimación de otros tipos de ruido del sensor
 clear; clc; close all;

 % Cargamos los datos
 load data_noise
 % Recorremos las 12 tomas y calculamos la  exposición media y la desviación estándar
 for k = 1:length(T)
    frame = G(:,:,k);
    % Exposición media del fragmento
    E(k) = mean2(frame);
    % Ruido total del fragmento
    S(k) = std2(frame);
 end
 % Gráfica de E vs T
 figure;
 plot(T, E, '-o');
 grid on;
 xlabel('Tiempo de exposición T (s)');
 ylabel('Exposición media E (ADU)');
 title('Ruido total frente a T');
 % Mostramos resultados
 fprintf('Valores de T:\n');
 fprintf('| %.4f |', T);
 fprintf('\n');
 fprintf('Valores de E:\n');
 fprintf('| %.4f |', E);
 fprintf('\n');
 fprintf('Valores de S:\n');
 fprintf('| %.4f |', S);
 fprintf('\n');

 % Gráfica de S vs E
 figure;
 plot(E, S, 'ro', 'LineWidth', 1.5, 'MarkerSize', 6);
 grid on;
 xlabel('Exposición media E (ADU)');
 ylabel('Desviación estándar S (ADU)');
 title('Ruido total frente a exposición');
 % Ajuste de S2
 S2 = S.^2;
 c = polyfit(E, S2, 2);
 % Reordemaos porque los coeficientes en la funcón son devueltos de mayor a menor
 c1 = c(3);
 c2 = c(2);
 c3 = c(1);
 % Mostrar resultados
 fprintf('\nCoeficientes del ajuste:\n');
 fprintf('c1 = %.6f\n', c1);
 fprintf('c2 = %.6f\n', c2);
 fprintf('c3 = %.6f\n', c3);
 fprintf( '-------------\n');
 % Crear vector de exposición y calcular la curva del ajuste
 e = 1:2000;
 s = sqrt(c1 + c2*e + c3*e.^2);
 % Superponer el ajuste sobre los datos medidos
 figure;
 plot(E, S, 'ro', 'LineWidth', 1.5, 'MarkerSize', 6);
 hold on;
 plot(e, s, 'b', 'LineWidth', 1.5);
 grid on;
 xlabel('Exposición media E (ADU)');
 ylabel('Desviación estándar S (ADU)');
 title('Ruido total frente a exposición y ajuste');
 oR = sqrt(c1); G = c2; K = sqrt(c3);
 disp(oR); disp(G);disp(K);

% 3.1)  Lectura y escalado de los datos RAW

raw=imread('raw.pgm');  


% 3.1) Obtencion y procesado imagen BW


% 3.2) Demultiplexado, paso a sRGB + gamma


% 3.3) Equilibrado de blancos

% 3.4) Algoritmo alternativo WB


% 3.5) Almacenamiento

