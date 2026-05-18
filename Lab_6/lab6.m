% ============================

% LABORATORIO 6 - FOTOGRAFÍA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================
clear;clc;close all;
addpath('FC_PROY6')
%1) Lectura de las imágenes y extracción de datos a usar 
T = [1/1000 1/500 1/250 1/125 1/60 1/30 1/15 1/8 1/4];

P = length(T);

img = imread('belg_1.jpg');
img_bw = rgb2gray(img);

[alto, ancho] = size(img_bw);

hdr_data = zeros(alto, ancho, P);

% Lectura de las imágenes
for i = 1:P
    
    nombre = sprintf('belg_%d.jpg', i);
    
    img = imread(nombre);
    
    img_bw = rgb2gray(img);
    
    img_bw = double(img_bw);
    
    hdr_data(:,:,i) = img_bw;
    
end

%muestra_HDR(hdr_data, T)

%Extracción de la información de un subconjunto de píxeles en las P tomas

function Zdata = sample_hdr(hdr_data,n)

Zdata = hdr_data(1:n:end, 1:n:end, :);
[filas, columnas, P] = size(Zdata);

Zdata = reshape(Zdata, filas*columnas, P);
validos = true(size(Zdata,1),1);

for i = 1:size(Zdata,1)
    
    v = Zdata(i,:);
    
    cond1 = all(diff(v) >= 0);
    cond2 = true;
    
    for k = 2:P-1
        if abs(v(k) - (v(k+1)+v(k-1))/2) > 25
            cond2 = false;
        end
    end
    
    validos(i) = cond1 && cond2;
end
Zdata = Zdata(validos,:);

% Verificacion de Zdata
if size(Zdata,1) == sum(validos)
    disp('Funciona correctamente')
end

Zdata = Zdata + 1;
end


% Zdata = sample_hdr(hdr_data,16);
% 
% % Gráfica de los píxeles pedidos
% figure;
% 
% plot(log2(T), Zdata(10,:), 'o-');
% hold on;
% 
% plot(log2(T), Zdata(140,:), 'o-');
% 
% plot(log2(T), Zdata(1700,:), 'o-');
% 
% plot(log2(T), Zdata(1565,:), 'o-');
% 
% xlabel('log_2(T)');
% ylabel('Valor del píxel');
% 
% legend('Pixel 10','Pixel 140','Pixel 1700','Pixel 1565');

% n = 8
datos_iniciales = hdr_data(1:8:end,1:8:end,:);

num_iniciales = size(datos_iniciales,1) * size(datos_iniciales,2);

Zdata8 = sample_hdr(hdr_data,8);

num_finales = size(Zdata8,1);

fprintf('n=8 -> puntos iniciales: %d\n', num_iniciales);
fprintf('n=8 -> puntos válidos: %d\n', num_finales);


% n = 16
datos_iniciales = hdr_data(1:16:end,1:16:end,:);

num_iniciales = size(datos_iniciales,1) * size(datos_iniciales,2);

Zdata16 = sample_hdr(hdr_data,16);

num_finales = size(Zdata16,1);

fprintf('n=16 -> puntos iniciales: %d\n', num_iniciales);
fprintf('n=16 -> puntos válidos: %d\n', num_finales);


%2) Resolución de las ecuaciones para obtener la función g(Z) 

fprintf("\n\n\n");
function [g,H,b] = solve_g(Zdata,T)

[N,P] = size(Zdata);

NE = N*(P-1) + 255;

i = [];
j = [];
v = [];

b = zeros(NE,1);

fila = 1;

for n = 1:N
    
    for p = 1:P-1
        
        z1 = Zdata(n,p);
        z2 = Zdata(n,p+1);
        
        % g(z2) - g(z1) - log2(T(p+1)/T(p)) = 0
        i = [i fila fila];
        j = [j z2 z1];
        v = [v 1 -1];
        
        b(fila) = log2(T(p+1)/T(p));
        
        fila = fila + 1;
        
    end
    
end


for k = 2:255
    
    % -g(k-1) + 2g(k) - g(k+1) = 0
    i = [i fila fila fila];
    j = [j k-1 k k+1];
    v = [v -1 2 -1];
    
    fila = fila + 1;
    
end


i = [i fila];
j = [j 129];
v = [v 1];

b(fila) = 0;


H = sparse(i,j,v,NE,256);


g = H\b;

end


Zdata = sample_hdr(hdr_data,8);

[g,H,b] = solve_g(Zdata,T);


fprintf('Numero de ecuaciones del sistema: %d\n', size(H,1));


fprintf('Numero de entradas no nulas en H: %d\n', nnz(H));


total_elementos = size(H,1) * size(H,2);

porcentaje = (nnz(H) / total_elementos) * 100;

fprintf('Porcentaje de entradas no nulas: %.6f %%\n', porcentaje);

num = sum(H~=0);

figure;
plot(num);

xlabel('Indice de columna');
ylabel('Numero de elementos no nulos');


fprintf('Numero de veces que aparece g10: %d\n', full(num(11)));

fprintf('Numero de veces que aparece g20: %d\n', full(num(21)));
