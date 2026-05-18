% ============================

% LABORATORIO 6 - FOTOGRAFIA COMPUTACIONAL
% Autor 1: [FLORES FLORES, DANIEL JAVIER]
% Autor 2: [LILLO RAMIREZ, LUCAS]

% ============================
clear; clc; close all;
addpath('FC_PROY6')

% 1) Lectura de las imagenes y extraccion de datos a usar
T = [1/1000 1/500 1/250 1/125 1/60 1/30 1/15 1/8 1/4];

P = length(T);

img = imread('belg_1.jpg');
img_bw = rgb2gray(img);

[alto, ancho] = size(img_bw);

hdr_data = zeros(alto, ancho, P);

% Lectura de las imagenes
for i = 1:P

    nombre = sprintf('belg_%d.jpg', i);

    img = imread(nombre);

    img_bw = rgb2gray(img);

    img_bw = double(img_bw);

    hdr_data(:,:,i) = img_bw;

end

% muestra_HDR(hdr_data, T)

% Zdata = sample_hdr(hdr_data,16);
%
% % Grafica de los pixeles pedidos
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
% ylabel('Valor del pixel');
%
% legend('Pixel 10','Pixel 140','Pixel 1700','Pixel 1565');

% n = 8
datos_iniciales = hdr_data(1:8:end,1:8:end,:);

num_iniciales = size(datos_iniciales,1) * size(datos_iniciales,2);

Zdata8 = sample_hdr(hdr_data,8);

num_finales = size(Zdata8,1);

fprintf('n=8 -> puntos iniciales: %d\n', num_iniciales);
fprintf('n=8 -> puntos validos: %d\n', num_finales);


% n = 16
datos_iniciales = hdr_data(1:16:end,1:16:end,:);

num_iniciales = size(datos_iniciales,1) * size(datos_iniciales,2);

Zdata16 = sample_hdr(hdr_data,16);

num_finales = size(Zdata16,1);

fprintf('n=16 -> puntos iniciales: %d\n', num_iniciales);
fprintf('n=16 -> puntos validos: %d\n', num_finales);


% 2) Resolucion de las ecuaciones para obtener la funcion g(Z)

fprintf("\n\n\n");

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


% Extraccion de la informacion de un subconjunto de pixeles en las P tomas
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


function [g,H,b] = solve_g(Zdata,T)

[N,P] = size(Zdata);

Neq = N*(P-1) + 254;
num_no_nulos = 2*N*(P-1) + 3*254;

i = zeros(num_no_nulos,1);
j = zeros(num_no_nulos,1);
v = zeros(num_no_nulos,1);

b = zeros(Neq,1);

fila = 1;
entrada = 1;

for n = 1:N

    valores = Zdata(n,:);
    [~, pos_ref] = min(abs(valores - 129));

    z_ref = valores(pos_ref);
    T_ref = T(pos_ref);

    for p = 1:P

        if p ~= pos_ref
            z = valores(p);

            i(entrada:entrada+1) = fila;
            j(entrada:entrada+1) = [z z_ref];
            v(entrada:entrada+1) = [1 -1];

            b(fila) = log2(T(p)/T_ref);

            fila = fila + 1;
            entrada = entrada + 2;
        end

    end

end

for k = 2:255

    i(entrada:entrada+2) = fila;
    j(entrada:entrada+2) = [k-1 k k+1];
    v(entrada:entrada+2) = [-1 2 -1];

    fila = fila + 1;
    entrada = entrada + 3;

end

H = sparse(i,j,v,Neq,256);

g = H\b;

end
